class WelcomeController < ApplicationController

  def new

  end

  def create
    auth = request.env['omniauth.auth']
  end
end
