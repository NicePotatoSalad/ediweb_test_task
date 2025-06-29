# Contains hooks like Before, After, AfterStep
# Aka conftest.py in pytest with written fixtures

# frozen_string_literal: true

require 'fileutils' # This is needed for `FileUtils.rm_rf` and `FileUtils.mkdir_p`

# The ScenarioData class needs to be loaded, it's typically loaded by env.rb
# or you could require_relative 'helpers/scenario_data' here too if env.rb doesn't do it.

Before do |_scenario|
  @scenario_data = ScenarioData.new 

  # Get the download directory path using the helper from step_helper.rb
  download_directory = get_download_directory_path

  # Remove the directory and all its contents if it exists
  if File.directory?(download_directory) # Check if the directory exists
    FileUtils.rm_rf(download_directory) # Remove it recursively (all files and subfolders)
    $logger.info("Директория загрузок очищена: #{download_directory}")
  end
  # Create the directory fresh, ensuring it's empty and ready for downloads
  FileUtils.mkdir_p(download_directory) # Create directory and any parent directories if they don't exist
end
