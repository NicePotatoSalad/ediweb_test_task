# frozen_string_literal: true

# --- Existing Steps ---

When(/^захожу на страницу "(.+?)"$/) do |url|
  visit url # Capybara method to go to a URL
  $logger.info("Страница #{url} открыта")
  sleep 1 # Pause for 1 second
end

When(/^ввожу в поисковой строке текст "([^"]*)"$/) do |text|
  # find("//input[@name='q']") uses XPath to locate the search input field
  query = find("//input[@name='q']")
  query.set(text) # Enters the text
  query.native.send_keys(:enter) # Simulates pressing Enter key
  $logger.info('Поисковый запрос отправлен')
  sleep 1
end

When(/^кликаю по строке выдачи с адресом (.+?)$/) do |url|
  # Finds a link element with a specific href and an h3 child (typical Google search result)
  link_first = find("//a[@href='#{url}/']/h3")
  link_first.click # Clicks the element
  $logger.info("Переход на страницу #{url} осуществлен")
  sleep 1
end

When(/^я должен увидеть текст на странице "([^"]*)"$/) do |text_page|
  sleep 1
  expect(page).to have_text text_page # Capybara assertion: checks if the text is on the current page
end

# --- NEW STEPS FOR DOWNLOAD SCENARIO ---

When(/^перехожу на вкладку "([^"]*)"$/) do |link_text|
  # Clicks a link with the given text. For Ruby's download page, it's "Загрузить".
  click_link link_text
  $logger.info("Перешел на вкладку '#{link_text}'")
  sleep 1
end

When(/^скачиваю последний стабильный релиз$/) do
  # Step 1: Find the download link.
  # We look for an <a> tag (link) whose 'href' attribute ends with ".tar.gz"
  # AND whose 'href' contains "ruby-" (to ensure it's a Ruby file)
  # AND whose text is "Скачать"
  # .match: :first ensures we get only the first matching element.
  download_link_element = find('a[href$=".tar.gz"][href*="ruby-"]', text: /Скачать/i, match: :first)

  # If no such link is found, raise an error immediately.
  unless download_link_element
    raise "Ошибка: Не удалось найти ссылку для скачивания последнего стабильного релиза (tar.gz)."
  end

  # Step 2: Get the expected filename from the link's href.
  # File.basename is a Ruby method that extracts the filename from a full path/URL.
  @scenario_data.expected_download_filename = File.basename(download_link_element[:href])
  $logger.info("Ожидаемое имя файла для скачивания: #{@scenario_data.expected_download_filename}")

  # Step 3: Click the download link.
  download_link_element.click
  $logger.info("Кликнул на ссылку для скачивания: #{@scenario_data.expected_download_filename}")

  # Step 4: Wait for the file to finish downloading.
  # `get_download_directory_path` is a helper 
  full_download_path = File.join(get_download_directory_path, @scenario_data.expected_download_filename)
  # `wait_for_file_to_download` is a helper 
  wait_for_file_to_download(full_download_path)
end

When(/^проверяю, что файл находится в директории загрузок$/) do
  # Step 1: Get the download directory path using the helper.
  download_dir = get_download_directory_path
  # Step 2: Construct the full path to the expected file.
  file_path = File.join(download_dir, @scenario_data.expected_download_filename)

  # Step 3: Assert that the file exists at that path.
  # `File.exist?(path)` is Ruby for checking if a file exists.
  expect(File.exist?(file_path)).to be true # 'be true' is RSpec matcher for boolean true
  $logger.info("Файл '#{@scenario_data.expected_download_filename}' найден в директории загрузок: #{download_dir}")
end