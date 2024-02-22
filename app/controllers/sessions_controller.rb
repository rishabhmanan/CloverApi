class SessionsController < ApplicationController

  def new
  end

  def create
    auth = request.env['omniauth.auth']
    session[:user_token] = auth.credentials.token
    session[:user_email] = auth.info.email
    session[:api_token] = '732ec82b-fc53-489d-0ca4-4bb73e1fa0d1'
    session[:merchant_id] = '34VTWYC23QZ01'
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
