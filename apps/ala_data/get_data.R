# Pull required data from AWS and store as .RData files
library(lubridate)
library(paws)
library(jsonlite)
library(stringr)
library(dplyr)
library(tidyr)

# Get object contents for a list of keys
# Behave differently for csv/json data
pull_aws_data <- function(keys, type = "json") {
  s3 <- paws::s3()
  lapply(keys, function(key) {
    obj <- s3$get_object(
      Bucket = Sys.getenv("AWS_BUCKET_ID"),
      Key = key
    )
    if (type == "json") {
      res <- fromJSON(rawToChar(obj$Body))
      # convoluted way to extract date
      res$date <- as_date(
        str_split(str_split(key, "/")[[1]][2], "[.]")[[1]][1],
        format = "%Y%m%d%H%M"
      )
      res
    } else {
      read.csv(text = rawToChar(obj$Body))
    }
  })
}


# Get vector of keys of all available objects
list_aws_objects <- function(prefix) {
  bucket_id <- Sys.getenv("AWS_BUCKET_ID")
  s3 <- paws::s3()
  objs <- s3$list_objects(Bucket = bucket_id, Prefix = prefix)
  obj_df <- data.frame(
    matrix(
      unlist(objs$Contents),
      nrow=length(objs$Contents),
      byrow=TRUE
    )
  )
  # Rename df with more helpful names
  names(obj_df) <- c("key", "last_modified", "etag", "size", "storage_class")
  if (prefix == "data_resource") {
    obj_df$size <- as.integer(obj_df$size)
    obj_df <- obj_df %>% filter(size > 20 & size < 23000)
  }
  return(obj_df$key)
}


save_dashboard_data <- function() {
  dashboard_keys <- list_aws_objects("dashboard")
  dashboard_objs <- pull_aws_data(dashboard_keys)
  save(dashboard_objs, file = 'data/dashboard_objs.RData')
}

save_dr_data <- function() {
  dr_keys <- list_aws_objects("data_resource")
  dr_objs <- pull_aws_data(dr_keys, type = "csv")
  dr_csv <- data.table::rbindlist(dr_objs)
  dr_csv$date <- as.Date(dr_csv$date)
  save(dr_csv, file = 'data/data_resource_counts.RData')
}

save_image_data <- function() {
  image_keys <- list_aws_objects("image")
  image_objs <- pull_aws_data(image_keys)
  image_data <- data.table::rbindlist(image_objs)
  save(image_data, file = 'data/image_data.RData')
}

# Get raw counts
get_counts <- function(dashboard_objs) {
  data.table::rbindlist(lapply(dashboard_objs, function(obj) {
    tibble_row(total = obj$totalRecords$total,
               duplicates = obj$totalRecords$duplicates, date = obj$date)
  }))
}


# Get basis of record counts
get_bor_counts <- function(dashboard_objs) {
  counts <- data.table::rbindlist(lapply(dashboard_objs, function(obj) {
    df <- as.data.frame(obj$basisOfRecord)
    other_cols_sum <- df %>%
      select(matches(c("Not.supplied", "Nomenclatural.checklist",
                       "Genomic.DNA", "Environmental.DNA"))) %>%
      rowSums()
    human_obs_sum <- df %>%
      select(matches(c("Image", "Sound", "Human.observation", "Video"))) %>%
      rowSums()
    df %>%
      select(-matches(c("Image", "Sound", "Nomenclatural.checklist",
                        "Not.supplied", "Genomic.DNA",
                        "Environmental.DNA", "Video"))) %>%
      mutate(Human.observation = human_obs_sum, Other = other_cols_sum) %>%
      pivot_longer(everything(), names_to = "basis_of_record",
                   values_to = "count") %>%
      mutate(date = obj$date)
  }))
}





