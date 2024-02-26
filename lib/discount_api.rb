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

  def get_orders_in_period(start_time, end_time)
    uri = URI("#{BASE_URI}/#{@merchant_id}/orders")
    uri.query = URI.encode_www_form(filter: "createdTime>='#{start_time}' and createdTime<='#{end_time}'")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    @headers.each { |key, value| request[key] = value }

    response = http.request(request)
    JSON.parse(response.body)
  end

  def calculate_total_discounts(start_time, end_time)
    response = get_orders_in_period(start_time, end_time)

    if response && response['elements']
      total_discounts = []

      response['elements'].each do |order|
        next unless order['discounts']

        order['discounts'].each do |discount|
          total_discounts << discount if discount['amount']
        end
      end

      total_discounts
    else
      puts "API response is nil or does not contain 'elements'"
      return []
    end
  end

end
