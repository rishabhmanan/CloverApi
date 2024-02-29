require "net/http"
require "json"

BASE_URI = "https://sandbox.dev.clover.com/v3/merchants".freeze

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
    start_time_ms = start_time.to_i * 1000
    end_time_ms = end_time.to_i * 1000
    uri = URI("#{BASE_URI}/#{@merchant_id}/orders?filter=createdTime>=#{start_time_ms}&filter=createdTime<=#{end_time_ms}")
    response = send_get_request(uri)
    return JSON.parse(response.body)["elements"] || []
  end

  def get_line_items_for_orders(orders)
    line_items = []
    orders.each do |order|
      line_items.concat(get_line_items(order["id"]))
    end
    line_items
  end

  def get_line_items(order_id)
    uri = URI("#{BASE_URI}/#{@merchant_id}/orders/#{order_id}/line_items")
    response = send_get_request(uri)
    parsed_response = JSON.parse(response.body)
    parsed_response["elements"] || []
  end

  def get_item(item_id)
    uri = URI("#{BASE_URI}/#{@merchant_id}/items/#{item_id}")
    response = send_get_request(uri)
    JSON.parse(response.body)
  end

  def calculate_revenue_per_product(start_time, end_time)
    response = get_orders(start_time, end_time)
    revenue_per_product = Hash.new(0)

    if response.is_a?(Array) && !response.empty?
      response.each do |order|
        if order.is_a?(Hash) && order.key?('id')
          order_id = order['id']
          line_items_response = get_line_items(order_id)

          if line_items_response.is_a?(Array) && !line_items_response.empty?
            line_items_response.each do |line_item|
              if line_item.is_a?(Hash) && line_item['id'] && line_item.key?('price')
                item_response = get_item(line_item['id'])

                if item_response.is_a?(Hash)
                  item_name = line_item['name']
                  revenue_per_product[item_name] += line_item['price'].to_f
                end
              end
            end
          else
            puts "Error: line_items_response is not an array"
          end
        else
          puts "Error: Order is not in the expected format"
        end
      end
    else
      puts "Error: Response is not an array or is empty"
    end

    revenue_per_product
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

api_token = "488e54cc-bd1f-b963-bfa7-6f732eb06c62"
merchant_id = "HT2V6ZWJEMHQ1"
revenue = RevenueApi.new(api_token, merchant_id)
start_time = Time.new(2023, 1, 1)
end_time = Time.new(2023, 12, 31)
# revenue_per_product = revenue.calculate_revenue_per_product(start_time, end_time)
