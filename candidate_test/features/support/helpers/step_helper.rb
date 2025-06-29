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