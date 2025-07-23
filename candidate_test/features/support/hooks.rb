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

After do |scenario|
  # Check if any users were created in this scenario and if $rest_wrap is available
  if @scenario_data.created_user_ids && $rest_wrap
    @scenario_data.created_user_ids.each do |user_id|
      begin
        # Attempt to delete each created user
        $rest_wrap.delete("/users/#{user_id}")
        $logger.info("Удален пользователь с ID: #{user_id} после сценария.")
      rescue StandardError => e
        $logger.warn("Не удалось удалить пользователя с ID #{user_id}: #{e.message}")
      end
    end
  end
end