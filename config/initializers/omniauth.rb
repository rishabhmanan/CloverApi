Rails.application.config.middleware.use OmniAuth::Builder do
  provider :oauth2, 'M2WQAHDKK08K4', '690d6f02-ae77-4a44-7b8d-bc70e693fa45',
  client_options: {
    site: 'https://sandbox.dev.clover.com',
    authorize_url: '/oauth/authorize',
    token_url: '/oauth/token'
  }
end
