require 'json'
require 'net/http'
require 'uri'

class TaxApi
  BASE_URI = 'https://sandbox.dev.clover.com/v3/merchants'.freeze

  def initialize(session)
    @api_token = session[:api_token]
    @merchant_id = session[:merchant_id]
    @headers = {
      'Authorization' => "Bearer #{@api_token}",
      'Content-Type' => 'application/json'
    }
  end

  def get_tax_rates(start_time, end_time)
    uri = URI("#{BASE_URI}/#{@merchant_id}/tax_rates")
    response = send_get_request(uri)
    JSON.parse(response.body)["elements"] || []
  rescue StandardError => e
    puts "Error occurred while fetching tax rates: #{e.message}"
    []
  end

  def calculate_total_taxes(start_time, end_time)
    response = get_tax_rates(start_time, end_time)
    total_taxes = 0

    if response
      response.each do |tax|
        total_taxes += tax['rate'].to_f if tax['rate']
      end
    else
      puts "No Tax Rates"
    end
  end

  private

  def send_get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    @headers.each { |key, value| request[key] = value }
    response = http.request(request)
    handle_response(response)
  rescue StandardError => e
    puts "Error occurred while sending HTTP request: #{e.message}"
    raise
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      response
    else
      raise "Request failed with status code: #{response.code}"
    end
  rescue StandardError => e
    puts "Error occurred while handling response: #{e.message}"
    raise
  end

end
