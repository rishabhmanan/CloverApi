class OAuthController < ApplicationController
  def initialize
    super
    @oauth_client = OAuth2::Client.new(
      Rails.configuration.x.oauth.client_id,
      Rails.configuration.x.oauth.client_secret,
      site: 'https://sandbox.dev.clover.com',
      authorize_url: '/oauth/authorize',
      token_url: '/oauth/token',
      redirect_uri: "http://localhost:3000/oauth_callback"
    )
  end

  def oauth_callback
    puts "OAuth callback received with params: #{params.inspect}"
    response = @oauth_client.auth_code.get_token(params[:code], {
      client_id: Rails.configuration.x.oauth.client_id,
      client_secret: Rails.configuration.x.oauth.client_secret
    })

    token = response.token
    session[:user_jwt] = { value: token, httponly: true }

    redirect_to api_path
  end

  def logout
    @oauth_client.request(:get, '/oauth/authorize', params: { action: 'logout' })

    reset_session

    redirect_to root_path
  end

  def login
    redirect_to @oauth_client.auth_code.authorize_url(scope: 'read_write'), allow_other_host: true
  end

  def authorize
    redirect_to @oauth_client.auth_code.authorize_url(scope: 'read_write'), allow_other_host: true
  end
end
