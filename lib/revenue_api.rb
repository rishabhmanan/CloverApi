require "net/http"
require "json"

BASE_URI = "https://api.clover.com/v3/merchants".freeze

class RevenueApi
  def initialize(api_token, merchant_id)
    @api_token = api_token
    @merchant_id = merchant_id
    @headers = {
      'Authorization' => "Bearer #{@api_token}",
      'Content-Type' => 'application/json'
    }
  end

  def get_orders(start_time, end_time)
    puts "Fetching orders from #{@merchant_id} between #{start_time} and #{end_time}"
    []
  end

  session = { api_token: '732ec82b-fc53-489d-0ca4-4bb73e1fa0d1', merchant_id: '34VTWYC23QZ01' }
  revenue_api = RevenueApi.new(api_token: session[:api_token], merchant_id: session[:merchant_id])

  def get_orders_in_period(start_time, end_time)
    uri = URI("#{BASE_URI}/#{@merchant_id}/orders?filter=createdTime>=#{start_time}&filter=createdTime<=#{end_time}")
    response = send_get_request(uri)
    JSON.parse(response.body)
  end

  def get_line_items(order_id)
    uri = URI("#{BASE_URI}/#{@merchant_id}/orders/#{order_id}/line_items")
    response = send_get_request(uri)
    JSON.parse(response.body)
  end

  def get_item(item_id)
    uri = URI("#{BASE_URI}/#{@merchant_id}/items/#{item_id}")
    response = send_get_request(uri)
    JSON.parse(response.body)
  end

  def calculate_revenue_per_product(start_time, end_time)
    response = get_orders_in_period(start_time, end_time)
    revenue_per_product = Hash.new(0)

    if response && response["elements"]
      response["elements"].each do |order|
        line_items_response = get_line_items(order["id"])
        if line_items_response && line_items_response["elements"]
          line_items_response["elements"].each do |line_item|
            item_response = get_item(line_item["item"]["id"])
            if item_response && item_response["name"] && line_item["price"]
              revenue_per_product[item_response["name"]] += line_item["price"].to_f
            end
          end
        end
      end
    end

    revenue_per_product
  end

  private

  def send_get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    @headers.each { |key, value| request[key] = value }
    http.request(request)
  end
end

api_token = "732ec82b-fc53-489d-0ca4-4bb73e1fa0d1"
merchant_id = "34VTWYC23QZ01"
revenue = RevenueApi.new(api_token, merchant_id)
start_time = Time.new(2023, 1, 1).to_i * 1000
end_time = Time.new(2023, 12, 31).to_i * 1000
revenue_per_product = revenue.calculate_revenue_per_product(start_time, end_time)
puts revenue_per_product
