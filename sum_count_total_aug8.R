#!/usr/bin/env Rscript

csv_path <- "/Users/markfisher/Sites/pcc_cr_mothbox_analyses/2026TaxonomicCompositionDataProcessing_aug_21_snapshot.csv"
data <- read.csv(csv_path, stringsAsFactors = FALSE)

get_early_late_date_matches <- function(date) {
	data[
		data$Date == date &
			(startsWith(data$Time, "00-45") | startsWith(data$Time, "03-45")),
	]
}

get_all_date_matches <- function(date) {
	data[
		data$Date == date,
	]
}

# Drops rows where CountTotal or CountMoths fails to coerce to numeric, so neither sum includes a partial row.
valid_count_rows <- function(matches) {
	count_total <- suppressWarnings(as.numeric(matches$CountTotal))
	count_moths <- suppressWarnings(as.numeric(matches$CountMoths))
	keep <- !is.na(count_total) & !is.na(count_moths)
	data.frame(CountTotal = count_total[keep], CountMoths = count_moths[keep])
}

calculate_total <- function(date) {
    early_late_matches <- get_early_late_date_matches(date)
    early_late_counts <- valid_count_rows(early_late_matches)
    totalInsect <- sum(early_late_counts$CountTotal)
    totalMoth <- sum(early_late_counts$CountMoths)

    all_matches <- get_all_date_matches(date)
    all_counts <- valid_count_rows(all_matches)
    totalInsectAll <- sum(all_counts$CountTotal)
    totalMothAll <- sum(all_counts$CountMoths)
    print(paste("Total Insect Count for", date, ":", totalInsect))
    print(paste("Total Moth Count for", date, ":", totalMoth))
    print(paste("Total Insect Count (All Times) for", date, ":", totalInsectAll))
    print(paste("Total Moth Count (All Times) for", date, ":", totalMothAll))
}

calculate_total("8/8/2026")

calculate_total("8/11/2026")

calculate_total("8/14/2026")

calculate_total("8/19/2026")