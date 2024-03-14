
download_and_unzip <- function(download_url, dest_dir, zip_file_name) {
  # Ensure the destination directory exists
  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir)
  }
  
  # Define the zip file path
  zip_file_path <- file.path(dest_dir, zip_file_name)
  
  # Download the zip file
  download.file(url = download_url, destfile = zip_file_path, method = "auto")
  
  # Unzip the file
  unzip(zipfile = zip_file_path, exdir = dest_dir)
}




split_data <- function(data, split_ratio = 0.8) {
  # Splitting the data into train and test sets
  set.seed(123) # For reproducibility
  training_sample <- sample(nrow(data), size = floor(nrow(data) * split_ratio))
  train_set <- data[training_sample, ]
  test_set <- data[-training_sample, ]
  rownames(train_set) <- NULL
  rownames(test_set) <- NULL
  
  # Return a list containing the train and test datasets
  return(list(train_set = train_set, test_set = test_set))
}





