require 'json'
require 'net/http'
require 'uri'
require 'time'

class PaymentAndFeesApi
  BASE_URI = 'https://sandbox.dev.clover.com/v3/merchants'.freeze

  def initialize(session)
    @access_token = session[:api_token]
    @merchant_id = session[:merchant_id]
    @headers = {
      'Authorization' => "Bearer #{@access_token}",
      'Content-Type' => 'application/json'
    }
    @fee_rates = {
      :credit_card => { id: 'MS3914YKQRARR', processor: 'Credit Card', fee_rate: 0.029 },
      :cash => { id: 'DMP0RY8QJWD5R', processor: 'Cash', fee_rate: 0.022 },
      :check => { id: 'AYKW6WQN4GFEG', processor: 'Check', fee_rate: 0.028 },
      :debit_card => { id: 'TNCPMGGZAYEQ4', processor: 'Debit Card', fee_rate: 0.027 }
    }
  end

  def get_payments_in_period(start_time, end_time)
    uri = URI("#{BASE_URI}/#{@merchant_id}/payments")
    start_time_ms = (start_time.utc.to_i * 1000).to_s
    end_time_ms = (end_time.utc.to_i * 1000).to_s

    uri.query = URI.encode_www_form(filter: "createdTime>=#{start_time_ms}", filter:"createdTime<=#{end_time_ms}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    @headers.each { |key, value| request[key] = value }

    response = http.request(request)

    if (response.code == "200")
      return JSON.parse(response.body)
    else
      return {}
    end

  end


  def calculate_revenue_per_processor(start_time_ms, end_time_ms)
    response = get_payments_in_period(start_time_ms, end_time_ms)
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
        tender = payment['tender']
        next unless tender && tender['id']

        processor = tender['id']
        processor_info = @fee_rates.values.find { |info| info[:id] == processor }

        if processor_info
          fee_rate = processor_info[:fee_rate]
        else
          puts "No fee rate defined for payment processor: #{processor}"
          next
        end

        fees_per_processor[processor] += payment['amount'] * fee_rate
      end
    else
      puts "No data available for processing"
    end

    fees_per_processor
  end

end
