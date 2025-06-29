# Custom class providing specific methods to an API
# Aka class that wrap requests library adding methods like get_users(), 
# create_user(), delete_user() and etc.

# frozen_string_literal: true

require 'json'

class RestWrapper
  attr_accessor :url, :login, :password

  def initialize(url:, login:, password:)
    @url = url
    @login = login
    @password = password
  end

  def get(current_url, _params = {})
    response = RestClient::Request.execute method: :get,
                                           url: compile_full_url(current_url),
                                           user: login,
                                           password: password,
                                           accept: 'application/json',
                                           headers: { content_type: 'application/json' }
    JSON.parse(response)
  rescue StandardError => e
    send_error e
  end

  def post(current_url, params = {})
    response = RestClient::Request.execute method: :post,
                                           url: compile_full_url(current_url),
                                           user: login,
                                           password: password,
                                           payload: params.to_json,
                                           headers: { content_type: 'application/json' }
    JSON.parse(response)
  rescue StandardError => e
    send_error e
  end

  def put(current_url, params = {})
    response = RestClient::Request.execute method: :put,
                                           url: compile_full_url(current_url),
                                           user: login,
                                           password: password,
                                           payload: params.to_json,
                                           headers: { content_type: 'application/json' }
    JSON.parse(response)
  rescue StandardError => e
    send_error e
  end

  def delete(current_url, params = {})
    response = RestClient::Request.execute method: :delete,
                                           url: compile_full_url(current_url),
                                           user: login,
                                           password: password,
                                           payload: params.to_json,
                                           headers: { content_type: 'application/json' }
    JSON.parse(response)
  rescue StandardError => e
    send_error e
  end

  private # Methods defined after 'private' can only be called from other methods within this class

  def send_error(exception)
    # Print the exception object itself for detailed debugging
    puts exception.inspect

    # Log the error using the global $logger
    $logger.error("API Ошибка: #{exception.message}")

    # If the exception has a 'response' (typical for RestClient errors), log more details
    if exception.respond_to?(:response) && exception.response
      $logger.error("Код ответа: #{exception.response.code}")
      $logger.error("Тело ответа: #{exception.response.body}")
      body = exception.response.body

      # Attempt to parse the body as JSON, if it's a string and not empty
      raise_message = if body.is_a?(String) && !body.empty?
                        # Use a rescue block here just in case the body isn't valid JSON
                        "Ошибка #{exception.response.code} с текстом #{JSON.parse(body)}" rescue "Ошибка #{exception.response.code} с текстом: #{body}"
                      else
                        "Ошибка #{exception.response.code} (без тела ответа)"
                      end
      raise raise_message # Re-raise a more descriptive error for Cucumber
    else
      # If no response object, just re-raise the original exception message
      raise "Произошла неизвестная ошибка: #{exception.message}"
    end
  end
  # This method combines the base URL with the specific endpoint to create a full URL
  # For example, if @url is 'https://api.example.com' and current_url
  def compile_full_url(current_url)
    @url + current_url
  end
end
