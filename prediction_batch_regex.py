#!/usr/bin/env python3
import argparse
import re
import shutil
import subprocess
from pathlib import Path

# Example usage: python3 prediction_batch_regex.py -- "/Users/markfisher/Downloads/wearySponge_2026-08-15/" "-" "/Users/markfisher/Sites/flat-bug/output_dir"


IMG_DIR = Path("/Users/markfisher/Sites/flat-bug/img_dir")
WEIGHTS_M = Path("/Users/markfisher/Sites/flat-bug/examples/tutorials/flat_bug_M.pt")
WEIGHTS_N = Path("/Users/markfisher/Sites/flat-bug/examples/tutorials/flat_bug_N.pt")


def run_predict(output_dir: Path, model: str) -> int:
	cmd = [
		"fb_predict",
		"-i",
		str(IMG_DIR),
		"-o",
		str(output_dir),
		"-w",
		str(WEIGHTS_M if model == "M" else WEIGHTS_N),
		"-g",
		"cpu",
		"--single-scale",
		"--fast",
		"-s",
		"0.5",
		"-v",
	]
	result = subprocess.run(cmd, check=False)
	return result.returncode


def main() -> None:
	parser = argparse.ArgumentParser(
		description=(
			"Move files matching a regex from a source directory into the FlatBug image "
			"directory, then run fb_predict after each move."
		)
	)
	parser.add_argument("path", help="Source directory to scan")
	parser.add_argument(
		"target_regex",
		help="Regular expression used to match file names in the source directory",
	)
	parser.add_argument(
		"output_dir",
		help="FlatBug output directory where per-image result folders are written",
	)
	parser.add_argument(
		"model",
		help="N for nano and M for medium. This selects the model weights to use for prediction.",
	)
	args = parser.parse_args()

	source_dir = Path(args.path).expanduser().resolve()
	output_dir = Path(args.output_dir).expanduser().resolve()
	model = args.model.upper()

	if not source_dir.is_dir():
		raise SystemExit(f"Source path is not a directory: {source_dir}")

	IMG_DIR.mkdir(parents=True, exist_ok=True)
	output_dir.mkdir(parents=True, exist_ok=True)

	pattern = re.compile(args.target_regex)

	matches = [
		p
		for p in sorted(source_dir.iterdir())
		if p.is_file() and pattern.search(p.name)
	]

	print(f"Found {len(matches)} matching files in {source_dir}")

	for src_file in matches:
		result_folder = output_dir / src_file.stem
		if result_folder.exists():
			print(f"Skipping {src_file.name}: output folder already exists at {result_folder}")
			continue

		dest_file = IMG_DIR / src_file.name

		# Avoid silent overwrites by making destination names unique.
		if dest_file.exists():
			stem = dest_file.stem
			suffix = dest_file.suffix
			counter = 1
			while True:
				candidate = IMG_DIR / f"{stem}_{counter}{suffix}"
				if not candidate.exists():
					dest_file = candidate
					break
				counter += 1

		print(f"Moving: {src_file} -> {dest_file}")
		shutil.move(str(src_file), str(dest_file))

		print("Running: fb_predict ...")
		return_code = run_predict(output_dir, model)
		if return_code != 0:
			print(f"fb_predict failed with exit code {return_code} after file {dest_file}")
		else:
			print(f"fb_predict succeeded after file {dest_file}")


if __name__ == "__main__":
	main()
