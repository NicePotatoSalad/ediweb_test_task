# Main environment file for Cucumber
# Aka conftest.py + __init__.py in Python

# frozen_string_literal: true

require 'rest-client'
require 'active_support/all'  # Provides Object#try, used in step_definitions
require 'capybara/cucumber' # Provides Cucumber integration with Capybara
require 'selenium-webdriver'
require 'yaml' # For loading YAML configuration files

# --- Load your custom helpers ---
# Make sure these paths are correct relative to env.rb
require_relative 'helpers/rest_wrapper'
require_relative 'helpers/logger' # This contains logger_initialize
require_relative 'helpers/class_extensions'
require_relative 'helpers/scenario_data' # This contains the ScenarioData class
require_relative 'helpers/step_helper' # This contains find_user_id, wait_for_file_to_download, get_download_directory_path

World(StepHelper)

def browser_setup(browser = 'firefox')
  case browser
  when 'chrome'
    Capybara.register_driver :chrome do |app|
      # Path to your chromedriver executable
      Selenium::WebDriver::Chrome.driver_path = 'configuration/chromedriver'
      # Define the directory where downloads should go
      # This MUST match the path used in your step_helper and hooks.rb
      download_directory = File.expand_path('features/tmp/', Dir.pwd)

      # Configure Chrome options
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--window-size=1920,1080') # Set browser window size

      # Configure download preferences directly in options for modern Selenium
      options.add_preference(:download,
                             directory_upgrade: true, # Indicates the preference is for a directory
                             prompt_for_download: false, # Do not ask where to save the file
                             default_directory: download_directory) # Set the default download folder
      
      # Create the Capybara Selenium driver instance
      Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
    end

    Capybara.default_driver = :chrome
    Capybara.page.driver.browser.manage.window.maximize # Maximize window after opening
    Capybara.default_selector = :xpath # Set default selector type to XPath
    Capybara.default_max_wait_time = 15 # Default wait time for Capybara elements

  else 
    Capybara.register_driver :firefox_driver do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      Selenium::WebDriver::Firefox.driver_path = 'configuration/geckodriver' # Path to your geckodriver executable
      
      # Define the directory where downloads should go for Firefox
      download_directory = File.expand_path('features/tmp/', Dir.pwd)

      profile['browser.download.folderList'] = 2 # 2 means custom location
      profile['browser.download.dir'] = download_directory # Set the download directory
      profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/octet-stream, text/xml' 
      profile['pdfjs.disabled'] = true # Disable PDF viewer in Firefox

      Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile, port: Random.rand(7000..7999)) 
    end
    
    Capybara.default_driver = :firefox_driver
  end
end
browser_setup('chrome')

configuration = YAML.load_file 'configuration/default.yml'
$rest_wrap = RestWrapper.new(url: 'https://testing4qa.ediweb.ru/api',
                              **configuration[:credentials]) # ** unpacks the hash into keyword arguments


# Initialize your custom logger (defined in helpers/logger.rb)
logger_initialize
