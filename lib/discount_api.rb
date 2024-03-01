require 'json'
require 'net/http'
require 'uri'

class DiscountApi
  BASE_URI = 'https://sandbox.dev.clover.com/v3/merchants'.freeze

  def initialize(session)
    @access_token = session[:api_token]
    @merchant_id = session[:merchant_id]
    @headers = {
      'Authorization' => "Bearer #{@access_token}",
      'Content-Type' => 'application/json'
    }
  end

  def get_discount(start_time, end_time)
    start_time_ms = start_time.to_i * 1000
    end_time_ms = end_time.to_i * 1000
    uri = URI("#{BASE_URI}/#{@merchant_id}/discounts")
    response = send_get_request(uri)
    JSON.parse(response.body)["elements"] || []
  rescue StandardError => e
    puts "Error occurred while fetching discounts: #{e.message}"
    []
  end

  def calculate_total_discounts(start_time, end_time)
    response = get_discount(start_time, end_time)
    total_discounts = response.select { |discount| discount['percentage'] }
    total_discounts.empty? ? nil : total_discounts
  end

  private

  def send_get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    @headers.each { |key, value| request[key] = value }
    response = http.request(request)
    handle_response(response)
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      response
    else
      raise "Request failed with status code: #{response.code}"
    end
  end
end
