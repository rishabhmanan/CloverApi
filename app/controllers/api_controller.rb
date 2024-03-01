class ApiController < ApplicationController
  def index
    session = { api_token: ENV['API_TOKEN'], merchant_id: ENV['MERCHANT_ID'] }
    initialize_apis(session)

    start_time = DateTime.now.prev_day(7)
    end_time = DateTime.now

    @revenue_per_processor = @payment_and_fees_api.calculate_revenue_per_processor(start_time, end_time)
    @processor_fees = @payment_and_fees_api.calculate_processor_fees(start_time, end_time)
    @total_discounts = @discount_api.calculate_total_discounts(start_time, end_time)
    @total_refunds = @refund_api.calculate_total_refunds(start_time, end_time)
    @total_taxes = @tax_api.calculate_total_taxes(start_time, end_time)
    @total_tips = @tips_api.calculate_total_tips(start_time, end_time)
    @orders = @revenue_api.get_orders(start_time, end_time)
    @line_items = @revenue_api.get_line_items_for_orders(@orders)
    @revenue_per_product = @revenue_api.calculate_revenue_per_product(start_time, end_time)

    rescue_nil_data
  end

  private

  def initialize_apis(session)
    @payment_and_fees_api = PaymentAndFeesApi.new(session)
    @discount_api = DiscountApi.new(session)
    @refund_api = RefundApi.new(session)
    @revenue_api = RevenueApi.new(session[:api_token], session[:merchant_id])
    @tax_api = TaxApi.new(session)
    @tips_api = TipsApi.new(session)
  end

  def rescue_nil_data
    if [@revenue_per_processor, @processor_fees, @total_discounts, @total_refunds, @total_taxes, @total_tips, @revenue_per_product].any?(&:nil?)
      flash[:error] = "Failed to retrieve data"
      initialize_nil_variables
    end
  end

  def initialize_nil_variables
    @revenue_per_processor ||= {}
    @processor_fees ||= {}
    @total_discounts ||= {}
    @total_refunds ||= {}
    @total_taxes ||= {}
    @total_tips ||= {}
    @revenue_per_product ||= {}
  end

  def log_error(exception)
    Rails.logger.error("An error occurred: #{exception.message}")
  end
end
