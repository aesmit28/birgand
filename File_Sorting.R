#This code can be modified to retrieve significant streamflow data for any USGS station
#By changing the path, the code can retrieve images/video from the significant dates
#The retrieved images will be copied and stored in a new folder


install.packages(c("dataRetrieval", "fs", "dplyr"))
library(dataRetrieval)
library(fs)
library(dplyr)

# Retrieve Streamflow Data
# Define USGS station ID (ex. Rocky Branch - 0208735012)
site_number <- "0208735012" 

# Define the date range for streamflow data "YYYY-MM-DD"
start_date <- "2025-02-11"
end_date <- "2025-02-18"

#Set parameter of choice
#"00060" - discharge in cfs
#"00035" - precipitation in mm (change to "00045" for inches)
parameter<- "00060"

# Define the parameter threshold
threshold <- .5  # (in, mm, etc.) Adjust as needed

# Retrieve streamflow data (parameterCd = "00060" corresponds to discharge)
streamflow_data <- readNWISdv(site_number, parameterCd = parameter, startDate = start_date, endDate = end_date)


# Filter for significant flow (only rows where flow > threshold)
significant_flow_data <- streamflow_data[streamflow_data$X_00060_00003 > threshold, ]  

# Extract only the dates where flow was significant
significant_flow_dates <- as.Date(significant_flow_data$Date)

# Print the significant flow dates
print(significant_flow_dates)



# Retrieve Video /Image Files Based on Streamflow Dates

# Set the directory where AVI/JPG files are stored
file_directory <- "/Users/birgand.lab/Desktop/2.17.25 Softball"  # Replace with the path to your video files

# List all AVI/JPG files in the directory
video_image_files <- list.files(file_directory, pattern = "\\.(AVI|JPG)$", full.names = TRUE)

# Get file info
file_info <- file.info(video_image_files)

# Extract and convert modification times to Date
file_dates <- as.Date(file_info$mtime)

# Filter video/image files that match significant flow dates (without time comparison)
matched_files <- video_image_files[file_dates %in% significant_flow_dates]

# Print matched files
print(matched_files)

#Create name of new file path
new_folder <- "/Users/birgand.lab/Desktop/2-17-25 Softball Good 2"

# Create the folder (if it doesn't already exist)
if (!dir.exists(new_folder)) {
  dir.create(new_folder)
}

# Move or copy the matched video files to the new folder
for (file in matched_files) {
  # Define the destination path for each video
  destination <- file.path(new_folder, basename(file))
  
  # Copy the file to the new folder
  file.copy(file, destination)
}

# Print message when done
cat("Matched video files have been copied to:", new_folder)
