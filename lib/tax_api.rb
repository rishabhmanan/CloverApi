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
    start_time_ms = start_time.to_i * 1000
    end_time_ms = end_time.to_i * 1000
    uri = URI("#{BASE_URI}/#{@merchant_id}/tax_rates")
    response = send_get_request(uri)
    return JSON.parse(response.body)["elements"] || []
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
    response
  end

end
