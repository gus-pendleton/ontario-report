# Loading packages

library(tidyverse)

# Reading in data

sample_data <- read_csv("data/sample_data.csv")

summarize(sample_data, average_cells = mean(cells_per_ml))

sample_data %>% 
  summarize(average_cells = mean(cells_per_ml))

# Filtering Rows

sample_data %>%
  filter(env_group == "Deep") %>%
  summarize(average_cells = mean(cells_per_ml))
  
# Calculate the average chlorophyll in the entire dataset
# Calculate the average chlorophyll just in Shallow September  

sample_data %>%
  summarize(avg_chl = mean(chlorophyll))

sample_data %>%
  filter(str_detect(env_group, "September")) %>%
  summarize(avg_chl = mean(chlorophyll))

# group_by

sample_data %>%
  group_by(env_group) %>%
  summarize(average_cells = mean(cells_per_ml),
            min_cells = min(cells_per_ml))

# Calculate the average temp per env_group

sample_data %>%
  group_by(env_group) %>%
  summarize(average_temperature = mean(temperature))

# mutate
# TN:TP

sample_data %>%
  mutate(temp_is_hot = temperature > 8) %>% 
  group_by(env_group, temp_is_hot) %>%
  summarize(avg_temp = mean(temperature),
            avg_cells = mean(cells_per_ml))
# selecting columns with select

sample_data %>%
  select(sample_id, depth)

sample_data %>%
  select(-env_group)

sample_data %>%
  select(sample_id:temperature)

sample_data %>%
  select(starts_with("total"))

# Create a dataframe with only sample_id, env_group, depth, temperature, and cells_per_ml

sample_data %>%
  select(sample_id:temperature)

sample_data %>%
  select(sample_id, env_group, depth, cells_per_ml, temperature)

sample_data %>%
  select(1:5)

sample_data %>%
  select(-starts_with("total"), -chlorophyll, -diss_org_carbon)

sample_data %>%
  select(-(total_nitrogen:chlorophyll))


# CLEANING DATA

taxon_clean <- read_csv("data/taxon_abundance.csv", skip = 2) %>% 
  select(-...10) %>%
  rename(sequencer = ...9) %>%
  select(-Lot_Number, -sequencer)

# Also remove the lot number and sequencer columns
# Assign this all to an object called "taxon_clean"

taxon_long <- taxon_clean %>%
  pivot_longer(cols = Proteobacteria:Cyanobacteria,
               names_to = "Phylum",
               values_to = "Abundance")

taxon_long %>%
  group_by(Phylum) %>%
  summarize(avg_abund = mean(Abundance))

taxon_long %>%
  ggplot() +
  aes(x = sample_id,
      y = Abundance,
      fill = Phylum) + 
  geom_col() + 
  theme(axis.text.x = element_text(angle = 90))

# Making long data wide

taxon_long %>%
  pivot_wider(names_from = "Phylum",
              values_from = "Abundance")

# JOINING DATA FRAMES
head(sample_data)

head(taxon_clean)

# Inner join

inner_join(sample_data, taxon_clean, by = "sample_id")

anti_join(sample_data, taxon_clean, by = "sample_id")

sample_data$sample_id

taxon_clean$sample_id

taxon_clean_goodSep <- taxon_clean %>%
  mutate(sample_id = str_replace(sample_id, pattern = "Sep", replacement = "September"))

sample_and_taxon <- inner_join(sample_data, taxon_clean_goodSep, by = "sample_id")

write_csv(sample_and_taxon, file = "data/sample_and_taxon.csv")

# Make a plot
# Ask: Where does Chloroflexi like to live?
install.packages("ggpubr")
library(ggpubr)
sample_and_taxon %>%
  ggplot() +
  aes(x = depth,
      y = Chloroflexi) + 
  geom_point() + 
  labs(x = "Depth (m)",
       y = "Chloroflexi relative abundance") + 
  geom_smooth(formula = y ~ log(x),
              method = "lm",
              color = "grey80",
              se = FALSE) +
  stat_regline_equation(formula = y ~ log(x),
                        aes(group = 1, 
                            label = sub("x", "log(x)", after_stat(eq.label)))) + 
  theme_classic()

# What is the average abundance 
# and standard deviation of Chloroflexi
# in our three env_groups

sample_and_taxon %>%
  group_by(env_group) %>%
  summarize(avg_chloro = mean(Chloroflexi),
            sd_chloro = sd(Chloroflexi))

