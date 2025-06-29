# Helper functions
# Aka utils.py or helper.py

# frozen_string_literal: true

require 'timeout' # We need this for Timeout.timeout
require 'fileutils' # We need this for FileUtils operations

def find_user_id(users_information:, user_login:)
  users_id = []
  users_information.each do |user|
    # .try(:[], 'login') is a safe way to access 'login' key, avoids error if 'user' is nil or doesn't have 'login'
    next unless user.try(:[], 'login') == user_login

    users_id << user['id'] # Add user's ID to the list
  end
  users_id.uniq! # Remove duplicate IDs

  if users_id.empty?
    raise "Пользователь с логином #{user_login} не найден." # If no users found, raise error
  elsif users_id.size != 1
    # If more than one user with the same login, this is an issue (login should be unique)
    raise "Логин пользователя неуникален! Найдено пользователей с аналогичным логином: #{users_id.size}, id: #{users_id.inspect}"
  end

  users_id.first # Return the single unique user ID
end

# --- NEW HELPER FOR FILE DOWNLOADS ---

# This function waits until a file appears in the given path and is not empty.
def wait_for_file_to_download(file_path, timeout_seconds = Capybara.default_max_wait_time)
  $logger.info("Ожидаю загрузку файла: #{file_path}")

  # Timeout.timeout will raise an error if the block of code doesn't finish within timeout_seconds
  Timeout.timeout(timeout_seconds) do
    loop do # This creates an infinite loop
      # Check if the file exists AND if its size is greater than 0
      break if File.exist?(file_path) && File.size(file_path) > 0
      sleep 0.5 
    end
  end

  $logger.info("Файл загружен: #{file_path}")
  file_path # return file_path

rescue Timeout::Error # Catch the timeout error if the file doesn't appear in time
  raise "Ошибка: Файл '#{File.basename(file_path)}' не был загружен в '#{File.dirname(file_path)}' в течение #{timeout_seconds} секунд."

rescue StandardError => e # Catch any other unexpected errors
  $logger.error("Произошла ошибка при ожидании загрузки файла: #{e.message}")
  raise e
end

# Getting a consistent path
def get_download_directory_path
  # This path should match what you configured in env.rb for Capybara downloads.
  File.expand_path('features/tmp/', Dir.pwd) # Dir.pwd is current working directory
end
