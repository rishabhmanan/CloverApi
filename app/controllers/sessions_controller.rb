class SessionsController < ApplicationController

  def new
  end

  def create
    auth = request.env['omniauth.auth']
    session[:user_token] = auth.credentials.token
    session[:user_email] = auth.info.email
    session[:api_token] = ENV['API_TOKEN']
    session[:merchant_id] = ENV['MERCHANT_ID']
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
