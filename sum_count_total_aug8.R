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

calculate_total <- function(date) {
    early_late_matches <- get_early_late_date_matches(date)
    totalInsect <- sum(as.numeric(early_late_matches$CountTotal), na.rm = TRUE)
    totalMoth <- sum(as.numeric(early_late_matches$CountMoths), na.rm = TRUE)

    all_matches <- get_all_date_matches(date)
    totalInsectAll <- sum(as.numeric(all_matches$CountTotal), na.rm = TRUE)
    totalMothAll <- sum(as.numeric(all_matches$CountMoths), na.rm = TRUE)
    print(paste("Total Insect Count for", date, ":", totalInsect))
    print(paste("Total Moth Count for", date, ":", totalMoth))
    print(paste("Total Insect Count (All Times) for", date, ":", totalInsectAll))
    print(paste("Total Moth Count (All Times) for", date, ":", totalMothAll))
}

calculate_total("8/8/2026")

calculate_total("8/11/2026")

calculate_total("8/14/2026")

calculate_total("8/19/2026")