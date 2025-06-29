# frozen_string_literal: true

# --- Existing Steps  ---

When(/^получаю информацию о пользователях$/) do
  # Calls the 'get' method on the $rest_wrap object, asking for '/users'
  users_full_information = $rest_wrap.get('/users')

  # Logs a message (using the $logger)
  $logger.info('Информация о пользователях получена')
  # Stores the full user information in the @scenario_data for this test scenario
  @scenario_data.users_full_info = users_full_information
end

When(/^проверяю (наличие|отсутствие) логина (\w+\.\w+) в списке пользователей$/) do |presence, login|
  # 'presence' will be "наличие" or "отсутствие"
  # 'login' will be something like "i.ivanov"

  # Gets a list of all logins from the full user info
  # .map { |f| f.try(:[], 'login') } is Ruby for: for each item 'f' in @scenario_data.users_full_info,
  # try to get its 'login' key. 'try' means if 'f' doesn't have 'login', it won't crash.
  logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }

  # Checks if the given 'login' is in the list of logins
  login_presents = logins_from_site.include?(login) # .include? is Ruby for 'in' operator

  if presence == 'наличие' # If the step says "проверяю наличие"
    message = "Логин #{login} присутствует в списке пользователей"
    # If login_presents is true, log info. If false, raise an error.
    login_presents ? $logger.info(message) : raise(message) # Ternary operator: CONDITION ? TRUE_CASE : FALSE_CASE
  else # If the step says "проверяю отсутствие"
    message = "Логин #{login} отсутствует в списке пользователей"
    # If login_presents is false, log info. If true, raise an error (because we expected absence).
    login_presents ? raise(message) : $logger.info(message)
  end
end

When(/^добавляю пользователя c логином (\w+\.\w+) именем (\w+) фамилией (\w+) паролем ([\d\w@!#]+)$/) do
|login, name, surname, password|
  # Calls the 'post' method on the $rest_wrap object, sending user data as a hash (like Python dictionary)
  response = $rest_wrap.post('/users', login: login,
                                       name: name,
                                       surname: surname,
                                       password: password,
                                       active: 1) # 'active: 1' means active = true
  $logger.info("Добавлен пользователь: #{response.inspect}") # .inspect shows the full object representation

  # Store the ID of the created user for potential cleanup later (e.g., in an After hook)
  @scenario_data.created_user_ids ||= [] # Initialize as empty array if nil (null)
  @scenario_data.created_user_ids << response['id'] if response['id'] # Add ID to the list
end

When(/^добавляю пользователя с параметрами:$/) do |data_table|
  # data_table.rows_hash converts the Gherkin table into a Ruby Hash
  # Example: | login | test.user |  becomes { 'login' => 'test.user' }
  user_data = data_table.rows_hash

  # API expects 'active' as 1 or 0 (integer).
  # If the table provides 'true' or 'false' (string), I need to convert it.
  if user_data.key?('active') # Checks if 'active' key exists in the hash
    user_data['active'] = (user_data['active'].downcase == 'true' ? 1 : 0)
  end

  # Now, use the $rest_wrap to post the user_data
  response = $rest_wrap.post('/users', user_data)
  $logger.info("Добавлен пользователь с параметрами: #{response.inspect}")
  @scenario_data.created_user_ids ||= []
  @scenario_data.created_user_ids << response['id'] if response['id']
end

When(/^нахожу пользователя с логином (\w+\.\w+)$/) do |login|
  # First, ensure I have the latest user list
  step %(получаю информацию о пользователях) # This is a Cucumber keyword to run another step

  # Call the helper function 'find_user_id' from step_helper.rb
  # Note: in Ruby, `method(arg1: value1, arg2: value2)` is how you pass keyword arguments
  user_id = find_user_id(users_information: @scenario_data.users_full_info,
                         user_login: login)

  # Store the found user's ID in @scenario_data.users_id.
  # We use a hash (dictionary) here to store IDs by login, e.g., {'t.task': 123, 'user.toedit': 456}
  @scenario_data.users_id ||= {} # Initialize as empty hash if nil
  @scenario_data.users_id[login] = user_id # Store the ID

  $logger.info("Найден пользователь #{login} с id:#{@scenario_data.users_id[login]}")
end
