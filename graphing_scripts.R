library(dplyr)
library(ggplot2)

# csv_path <- "/Users/markfisher/Downloads/2026 Taxonomic Composition - CanUseSingleMinute_.csv"
csv_path <- "/Users/markfisher/Sites/pcc_cr_mothbox_analyses/2026TaxonomicCompositionDataProcessing_aug_21_snapshot.csv"
data <- read.csv(csv_path, stringsAsFactors = FALSE)

# Extract the hour prefix (e.g. "21" from "21-01-23") to bucket entries
data$Hour <- substr(data$Time, 1, 2)

hours_of_interest <- c("21", "22", "23", "00", "01", "02", "03")

summary_df <- data %>%
  filter(Hour %in% hours_of_interest) %>%
  group_by(Hour) %>%
  summarise(
    AvgCountTotal = mean(CountTotal, na.rm = TRUE),
    AvgCountMoths = mean(CountMoths, na.rm = TRUE)
  ) %>%
  mutate(Hour = factor(Hour, levels = hours_of_interest)) %>%
  arrange(Hour)

print(summary_df)

plot_df <- summary_df %>%
  tidyr::pivot_longer(
    cols = c(AvgCountTotal, AvgCountMoths),
    names_to = "Metric",
    values_to = "Average"
  )

ggplot(plot_df, aes(x = Hour, y = Average, color = Metric, group = Metric)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Average CountTotal and CountMoths by Hour",
    x = "Hour",
    y = "Average Count",
    color = "Metric"
  ) +
  theme_minimal()
