Rails.application.config.middleware.use OmniAuth::Builder do
  provider :oauth2, ENV['APP_ID'], ENV['APP_SECRET'],
  client_options: {
    site: 'https://sandbox.dev.clover.com',
    authorize_url: '/oauth/authorize',
    token_url: '/oauth/token'
  }
end
