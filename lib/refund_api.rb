require 'json'
require 'net/http'
require 'uri'

class RefundApi
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

  def calculate_total_refunds(start_time, end_time)
    response = get_orders_in_period(start_time, end_time)
    total_refunds = 0

    if response && response['elements']
      response['elements'].each do |order|
        next unless order['lineItems']

        order['lineItems'].each do |item|
          total_refunds += item['refunded'].to_f if item['refunded']
        end
      end
    else
      puts "No data available for processing"
    end
  end
end
