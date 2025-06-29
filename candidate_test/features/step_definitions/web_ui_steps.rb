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

