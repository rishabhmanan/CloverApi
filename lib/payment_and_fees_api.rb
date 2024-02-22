require 'json'
require 'net/http'
require 'uri'

class PaymentAndFeesApi
  BASE_URI = 'https://api.clover.com/v3/merchants'.freeze

  def initialize(session)
    @access_token = session[:api_token]
    @merchant_id = session[:merchant_id]
    @headers = {
      'Authorization' => "Bearer #{@access_token}",
      'Content-Type' => 'application/json'
    }
    @fee_rates = {
      'Visa' => 0.029,
      'MasterCard' => 0.027
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

  def calculate_revenue_per_processor(start_time, end_time)
    response = get_payments_in_period(start_time, end_time)
    revenue_per_processor = Hash.new(0)

    if response && response['elements']
      response['elements'].each do |payment|
        processor = payment['tender']['label']
        revenue_per_processor[processor] += payment['amount']
      end
    else
      puts "No data available for processing"
    end

    revenue_per_processor
  end

  def calculate_processor_fees(start_time, end_time)
    response = get_payments_in_period(start_time, end_time)
    fees_per_processor = Hash.new(0)

    if response && response['elements']
      response['elements'].each do |payment|
        processor = payment['tender']['label']
        fee_rate = @fee_rates[processor]
        if fee_rate
          fees_per_processor[processor] += payment['amount'] * fee_rate
        else
          puts "No fee rate defined for payment processor: #{processor}"
        end
      end
    else
      puts "No data available for processing"
    end
  end
end
