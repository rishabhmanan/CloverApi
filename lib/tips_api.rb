require 'json'
require 'net/http'
require 'uri'

class TipsApi
  BASE_URI = 'https://api.clover.com/v3/merchants'.freeze

  def initialize(session)
    @access_token = session[:api_token]
    @merchant_id = session[:merchant_id]
    @headers = {
      'Authorization' => "Bearer #{@access_token}",
      'Content-Type' => 'application/json'
    }
  end

  def get_payments_in_period(start_time, end_time)
    uri = URI("#{BASE_URI}/#{@merchant_id}/payments")
    uri.query = URI.encode_www_form(filter: "createdTime>='#{start_time}' and createdTime<='#{end_time}'")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    @headers.each { |key, value| request[key] = value }

    response = http.request(request)
    JSON.parse(response.body)
  end

  def calculate_total_tips(start_time, end_time)
    response = get_payments_in_period(start_time, end_time)
    total_tips = 0

    response['elements'].each do |payment|
      total_tips += payment['tipAmount'].to_f if payment['tipAmount']
    end

    total_tips
  end
end
