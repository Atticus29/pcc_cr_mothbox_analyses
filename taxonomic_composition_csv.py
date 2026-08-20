#!/usr/bin/env python3
import argparse
import csv
import re
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Optional, Set, Tuple

CSV_HEADER = [
	"Date",
	"Time",
	"Filename",
	"Location",
	"CountTotal",
	"CountMoths",
	"NonMothOrders",
	"MothFamilies",
	"Notes",
]
OUTPUT_FOLDER_PATTERN = re.compile(
	r"^.*wearySponge_(\d+-\d+-\d+)T(.*)(-06-00.*)$"
)


def normalize_date(value: str) -> str:
	for date_format in ("%m/%d/%Y", "%Y-%m-%d"):
		try:
			return datetime.strptime(value, date_format).strftime("%Y-%m-%d")
		except ValueError:
			continue
	return value


def read_existing_keys(csv_path: Path) -> Set[Tuple[str, str]]:
	if not csv_path.is_file() or csv_path.stat().st_size == 0:
		return set()

	with csv_path.open(newline="") as csv_file:
		reader = csv.DictReader(csv_file)
		return {
			(normalize_date(row.get("Date", "")), row.get("Time", ""))
			for row in reader
			if row.get("Date") and row.get("Time")
		}


def make_csv_row(result_folder: Path) -> Optional[List[str]]:
	match = OUTPUT_FOLDER_PATTERN.match(result_folder.name)
	if match is None:
		return None

	time = match.group(2)
	original_date_str = match.group(1)
	date_obj = datetime.strptime(original_date_str, "%Y-%m-%d")
	# Past-midnight captures (00-04h) are logged under the prior night's date; roll them forward.
	if time[:2] in ("00", "01", "02", "03", "04"):
		date_obj += timedelta(days=1)
	date = date_obj.strftime("%m/%d/%Y")
	filename = result_folder.name.replace(
		original_date_str, date_obj.strftime("%Y-%m-%d"), 1
	)
	crops_dir = result_folder / "crops"
	count_total = (
		sum(1 for path in crops_dir.iterdir() if path.is_file())
		if crops_dir.is_dir()
		else 0
	)
	return [date, time, filename, "", str(count_total), "", "", "", ""]


def append_row(csv_path: Path, row: List[str]) -> None:
	needs_header = not csv_path.is_file() or csv_path.stat().st_size == 0
	with csv_path.open("a", newline="") as csv_file:
		writer = csv.writer(csv_file)
		if needs_header:
			writer.writerow(CSV_HEADER)
		writer.writerow(row)


def main() -> None:
	parser = argparse.ArgumentParser(
		description=(
			"Scan FlatBug output folders and add missing rows to the taxonomic composition CSV."
		)
	)
	parser.add_argument(
		"output_dir",
		help="FlatBug output directory containing prediction result folders",
	)
	parser.add_argument(
		"--csv",
		dest="csv_path",
		default=Path(__file__).resolve().parent / "2026TaxonomicComposition.csv",
		type=Path,
		help="CSV path (default: 2026TaxonomicComposition.csv beside this script)",
	)
	args = parser.parse_args()

	output_dir = Path(args.output_dir).expanduser().resolve()
	csv_path = args.csv_path.expanduser().resolve()
	if not output_dir.is_dir():
		raise SystemExit(f"Output path is not a directory: {output_dir}")

	existing_keys = read_existing_keys(csv_path)
	folders = sorted(path for path in output_dir.rglob("*") if path.is_dir())
	added_count = 0
	skipped_count = 0

	for result_folder in folders:
		row = make_csv_row(result_folder)
		if row is None:
			continue

		key = (normalize_date(row[0]), row[1])
		if key in existing_keys:
			skipped_count += 1
			continue

		append_row(csv_path, row)
		existing_keys.add(key)
		added_count += 1
		print(f"Added row for {row[0]} {row[1]} from {result_folder}")

	print(f"Added {added_count} row(s); skipped {skipped_count} existing row(s)")
	print(f"CSV: {csv_path}")


if __name__ == "__main__":
	main()
