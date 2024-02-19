class OAuthController < ApplicationController
  def initialize
    @oauth_client = OAuth2::Client.new(Rails.configuration.x.oauth.client_id,
                                       Rails.configuration.x.oauth.client_secret,
                                       authorize_url: '/oauth2/authorize',
                                       site: Rails.configuration.x.oauth.idp_url,
                                       token_url: '/oauth2/token',
                                       redirect_uri: Rails.configuration.x.oauth.redirect_uri)
  end

  def oauth_callback
    response = @oauth_client.auth_code.get_token(params[:code])

    token = response.to_hash[:access_token]

    begin
      decoded = TokenDecoder.new(token, @oauth_client.id).decode
    rescue Exception => error
      "An unexpected exception occurred: #{error.inspect}"
      head :forbidden
      return
    end

    session[:user_jwt] = {value: decoded, httponly: true}

    redirect_to root_path
  end

  def logout
    @oauth_client.request(:get, 'oauth2/logout')

    reset_session

    redirect_to root_path
  end

  def login
    redirect_to @oauth_client.auth_code.authorize_url
  end
end
