#!/usr/bin/env Rscript

csv_path <- "/Users/markfisher/Sites/pcc_cr_mothbox_analyses/2026TaxonomicComposition.csv"
data <- read.csv(csv_path, stringsAsFactors = FALSE)

get_early_late_date_matches <- function(date) {
	data[
		data$Date == date &
			(startsWith(data$Time, "00-45") | startsWith(data$Time, "03-45")),
	]
}

get_early_late_date_whole_hour_matches <- function(date) {
	data[
		data$Date == date &
			(startsWith(data$Time, "00-") | startsWith(data$Time, "03-")),
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

# R equivalent of JS string.split(","): returns a list of character vectors, one per input string.
split_on_comma <- function(strings) {
    lapply(strsplit(strings, ","), trimws)
}

get_taxa <- function(matches) {
    # get the data where matches$Date == date and matches$Time is "00-45"
    midnight_moths <- split_on_comma(matches[startsWith(matches$Time, "00-45"), "MothFamilies"])
    midnight_nonMoths <- split_on_comma(matches[startsWith(matches$Time, "00-45"), "NonMothOrders"])
    midnight_taxa <- list(
        moths=midnight_moths,
        nonMoths=midnight_nonMoths
    )
    # get the data where matches$Date == date and matches$Time is "03-45"
    three_am_moths <- split_on_comma(matches[startsWith(matches$Time, "03-45"), "MothFamilies"])
    three_am_nonMoths <- split_on_comma(matches[startsWith(matches$Time, "03-45"), "NonMothOrders"])
    three_am_taxa <- list(
        moths=three_am_moths,
        nonMoths=three_am_nonMoths
    )
    return(list(
        midnight = midnight_taxa,
        three_am = three_am_taxa
    ))
}

# Flattens a split taxa list into a single comma-separated string for printing.
format_taxa <- function(taxa) {
    paste(unlist(taxa), collapse = ", ")
}

get_taxa_whole_hour <- function(matches) {
    get_union <- function(sub_matches, column) {
        raw_list <- split_on_comma(sub_matches[, column])
        unlisted <- unlist(raw_list)
        unlisted <- unlisted[unlisted != "" & !is.na(unlisted)]
        unique(unlisted)
    }

    midnight_matches <- matches[startsWith(matches$Time, "00-"), ]
    midnight_taxa <- list(
        moths = get_union(midnight_matches, "MothFamilies"),
        nonMoths = get_union(midnight_matches, "NonMothOrders")
    )

    three_am_matches <- matches[startsWith(matches$Time, "03-"), ]
    three_am_taxa <- list(
        moths = get_union(three_am_matches, "MothFamilies"),
        nonMoths = get_union(three_am_matches, "NonMothOrders")
    )

    return(list(
        midnight = midnight_taxa,
        three_am = three_am_taxa
    ))
}

calculate_total <- function(date, justTaxa=FALSE) {
    early_late_matches <- get_early_late_date_matches(date)
    early_late_taxa <- get_taxa(early_late_matches)
    print(paste("Moths for", date, "at 00-45:", format_taxa(early_late_taxa$midnight$moths)))
    print(paste("Non-moths for", date, "at 00-45:", format_taxa(early_late_taxa$midnight$nonMoths)))
    print(paste("Moths for", date, "at 03-45:", format_taxa(early_late_taxa$three_am$moths)))
    print(paste("Non-moths for", date, "at 03-45:", format_taxa(early_late_taxa$three_am$nonMoths)))
    if(!justTaxa){
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
}

calculate_total_whole_hour <- function(date, justTaxa=FALSE) {
    whole_hour_matches <- get_early_late_date_whole_hour_matches(date)
    whole_hour_taxa <- get_taxa_whole_hour(whole_hour_matches)
    print(paste("Moths for", date, "during 00:xx hour:", format_taxa(whole_hour_taxa$midnight$moths)))
    print(paste("Non-moths for", date, "during 00:xx hour:", format_taxa(whole_hour_taxa$midnight$nonMoths)))
    print(paste("Moths for", date, "during 03:xx hour:", format_taxa(whole_hour_taxa$three_am$moths)))
    print(paste("Non-moths for", date, "during 03:xx hour:", format_taxa(whole_hour_taxa$three_am$nonMoths)))
    if(!justTaxa){
      whole_hour_counts <- valid_count_rows(whole_hour_matches)
      totalInsect <- sum(whole_hour_counts$CountTotal)
      totalMoth <- sum(whole_hour_counts$CountMoths)
  
      all_matches <- get_all_date_matches(date)
      all_counts <- valid_count_rows(all_matches)
      totalInsectAll <- sum(all_counts$CountTotal)
      totalMothAll <- sum(all_counts$CountMoths)
      print(paste("Total Insect Count (00 & 03 Hours) for", date, ":", totalInsect))
      print(paste("Total Moth Count (00 & 03 Hours) for", date, ":", totalMoth))
      print(paste("Total Insect Count (All Times) for", date, ":", totalInsectAll))
      print(paste("Total Moth Count (All Times) for", date, ":", totalMothAll))
    }
}

calculate_total("8/7/2026", TRUE)
calculate_total("8/8/2026")
calculate_total("8/9/2026", TRUE)
calculate_total("8/10/2026", TRUE)
calculate_total("8/11/2026")
calculate_total("8/12/2026", TRUE)
calculate_total("8/13/2026", TRUE)
calculate_total("8/14/2026")
calculate_total("8/15/2026", TRUE)
calculate_total("8/16/2026", TRUE)
calculate_total("8/17/2026", TRUE)
calculate_total("8/18/2026", TRUE)
calculate_total("8/19/2026")
calculate_total("8/20/2026")
calculate_total("8/21/2026", TRUE)
calculate_total("8/22/2026", TRUE)
calculate_total("8/23/2026", TRUE)
calculate_total("8/24/2026", TRUE)
calculate_total("8/25/2026", TRUE)

calculate_total_whole_hour("8/7/2026", TRUE)
calculate_total_whole_hour("8/8/2026")
calculate_total_whole_hour("8/9/2026", TRUE)
calculate_total_whole_hour("8/10/2026", TRUE)
calculate_total_whole_hour("8/11/2026")
calculate_total_whole_hour("8/12/2026", TRUE)
calculate_total_whole_hour("8/13/2026", TRUE)
calculate_total_whole_hour("8/14/2026")
calculate_total_whole_hour("8/15/2026", TRUE)
calculate_total_whole_hour("8/16/2026", TRUE)
calculate_total_whole_hour("8/17/2026", TRUE)
calculate_total_whole_hour("8/18/2026", TRUE)
calculate_total_whole_hour("8/19/2026")
calculate_total_whole_hour("8/20/2026")
calculate_total_whole_hour("8/21/2026", TRUE)
calculate_total_whole_hour("8/22/2026", TRUE)
calculate_total_whole_hour("8/23/2026", TRUE)
calculate_total_whole_hour("8/24/2026", TRUE)
calculate_total_whole_hour("8/25/2026", TRUE)