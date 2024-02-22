require 'json'
require 'net/http'
require 'uri'

class TaxApi
  BASE_URI = 'https://api.clover.com/v3/merchants'.freeze

  def initialize(session)
    @api_token = session[:api_token]
    @merchant_id = session[:merchant_id]
    @headers = {
      'Authorization' => "Bearer #{@api_token}",
      'Content-Type' => 'application/json'
    }
  end

  def get_orders_in_period(start_time, end_time)
    uri = URI("#{BASE_URI}/#{@merchant_id}/orders")
    uri.query = URI.encode_www_form(filter: "createdTime>=#{start_time}&createdTime<=#{end_time}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    @headers.each { |key, value| request[key] = value }

    response = http.request(request)
    JSON.parse(response.body)
  end

  def calculate_total_taxes(start_time, end_time)
    response = get_orders_in_period(start_time, end_time)
    total_taxes = 0

    if response && response['elements']
      response['elements'].each do |order|
        total_taxes += order['taxAmount'].to_f if order['taxAmount']
      end
    else
      puts "No data available for processing"
    end
  end
end
