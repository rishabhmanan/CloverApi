require 'net/http'
require 'json'
require 'date'

class RevenueApi
  BASE_URL = 'https://api.clover.com/v3/merchants/'

  def initialize(session)
    @api_token = session[:api_token]
    @merchant_id = session[:merchant_id]
  end

  def get_orders(start_time, end_time)
    url = "#{BASE_URL}#{@merchant_id}/orders?createdTime=#{start_time}&createdTime=#{end_time}"
    response = api_request(url)
    JSON.parse(response.body)
  end

  def get_line_items(order_id)
    url = "#{BASE_URL}#{@merchant_id}/orders/#{order_id}/line_items"
    response = api_request(url)
    JSON.parse(response.body)
  end

  def get_item_name(item_id)
    url = "#{BASE_URL}#{@merchant_id}/items/#{item_id}"
    response = api_request(url)
    JSON.parse(response.body)['name']
  end

  private

  def api_request(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{@api_token}"
    http.request(request)
  end
end

def calculate_revenue_per_product(orders, api)
  revenue_per_product = Hash.new(0)

  orders.each do |order|
    line_items = api.get_line_items(order['id'])
    line_items.each do |line_item|
      item_name = api.get_item_name(line_item['item']['id'])
      revenue_per_product[item_name] += line_item['price'].to_f
    end
  end

  revenue_per_product
end

session = {
  api_token: '704d4b09-345e-4c35-9f86-7df0f8907d17',
  merchant_id: '34VTWYC23QZ01'
}

start_time = DateTime.now.prev_day(7).strftime('%Y-%m-%dT00:00:00Z')
end_time = DateTime.now.strftime('%Y-%m-%dT23:59:59Z')

api = RevenueApi.new(session)
orders = api.get_orders(start_time, end_time)
revenue_per_product = calculate_revenue_per_product(orders, api)

puts "Revenue per Product:"
revenue_per_product.each do |product, revenue|
  puts "#{product}: $#{revenue}"
end
