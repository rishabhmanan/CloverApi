Rails.application.config.middleware.use OmniAuth::Builder do
  provider :clover, ENV["USERID"], ENV["SECRET"]
end
