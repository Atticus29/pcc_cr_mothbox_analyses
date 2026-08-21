#!/usr/bin/env Rscript

csv_path <- "/Users/markfisher/Sites/pcc_cr_mothbox_analyses/2026TaxonomicCompositionDataProcessing_aug_21_snapshot.csv"
data <- read.csv(csv_path, stringsAsFactors = FALSE)

get_matches <- function(date) {
	data[
		data$Date == date &
			(startsWith(data$Time, "00-45") | startsWith(data$Time, "03-45")),
	]
}

calculate_total <- function(date) {
    matches <- get_matches(date)
    totalInsect <- sum(as.numeric(matches$CountTotal), na.rm = TRUE)
    totalMoth <- sum(as.numeric(matches$CountMoths), na.rm = TRUE)
    print(paste("Total Insect Count for", date, ":", totalInsect))
    print(paste("Total Moth Count for", date, ":", totalMoth))
    # return(list(totalInsect = totalInsect, totalMoth = totalMoth))
}

calculate_total("8/8/2026")

calculate_total("8/11/2026")

calculate_total("8/14/2026")

calculate_total("8/19/2026")