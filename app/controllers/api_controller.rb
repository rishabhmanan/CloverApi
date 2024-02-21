class ApiController < ApplicationController
  def index
    api_token = session[:api_token]
    merchant_id = session[:merchant_id]

    @payment_and_fees_api = PaymentAndFeesApi.new(session)
    @discount_api = DiscountApi.new(session)
    @refund_api = RefundApi.new(session)
    @revenue_api = RevenueApi.new(api_token)
    @tax_api = TaxApi.new(session)
    @tips_api = TipsApi.new(session)

    start_time = DateTime.now.prev_day(7).strftime('%Y-%m-%dT00:00:00Z')
    end_time = DateTime.now.strftime('%Y-%m-%dT23:59:59Z')

    @revenue_per_processor = @payment_and_fees_api.calculate_revenue_per_processor(start_time, end_time)
    @processor_fees = @payment_and_fees_api.calculate_processor_fees(start_time, end_time)
    @total_discounts = @discount_api.calculate_total_discounts(start_time, end_time)
    @total_refunds = @refund_api.calculate_total_refunds(start_time, end_time)
    @total_taxes = @tax_api.calculate_total_taxes(start_time, end_time)
    @total_tips = @tips_api.calculate_total_tips(start_time, end_time)
    orders = @revenue_api.get_orders(merchant_id, start_time, end_time)
    @revenue_per_product = calculate_revenue_per_product(orders, @revenue_api)

    if [@revenue_per_processor, @processor_fees, @total_discounts, @total_refunds, @total_taxes, @total_tips, @revenue_per_product].any?(&:nil?)
      flash[:error] = "Failed to retrieve data"
      @revenue_per_processor ||= {}
      @processor_fees ||= {}
      @total_discounts ||= {}
      @total_refunds ||= {}
      @total_taxes ||= {}
      @total_tips ||= {}
      @revenue_per_product ||= {}
    end
  end

  private

  def calculate_revenue_per_product(orders, api)
    revenue_per_product = Hash.new(0)

    orders.each do |order|
      line_items = api.get_line_items(session[:merchant_id], order['id'])
      line_items.each do |line_item|
        item_name = api.get_item_name(session[:merchant_id], line_item['item']['id'])
        revenue_per_product[item_name] += line_item['price']
      end
    end

    revenue_per_product
  end
end
