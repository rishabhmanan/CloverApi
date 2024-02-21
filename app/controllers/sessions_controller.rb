class SessionsController < ApplicationController

  def new
  end

  def create
    auth = request.env['omniauth.auth']
    session[:user_token] = auth.credentials.token
    session[:user_email] = auth.info.email
    session[:api_token] = '704d4b09-345e-4c35-9f86-7df0f8907d17'
    session[:merchant_id] = '34VTWYC23QZ01'
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
