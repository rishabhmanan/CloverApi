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

  def get_orders(start_time, end_time)
    start_time_ms = start_time.to_i * 1000
    end_time_ms = end_time.to_i * 1000
    uri = URI("#{BASE_URI}/#{@merchant_id}/orders?filter=createdTime>=#{start_time_ms}&filter=createdTime<=#{end_time_ms}")
    response = send_get_request(uri)
    return JSON.parse(response.body)["elements"] || []
  end

  def calculate_total_refunds(start_time, end_time)
    response = get_orders(start_time, end_time)
    total_refunds = 0

    if response
      response.each do |order|
        next unless order['lineItems']

        order['lineItems'].each do |item|
          total_refunds += item['refunded'].to_f if item['refunded']
        end
      end
    else
      puts "No data available for processing"
      return 0
    end

    total_refunds
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
