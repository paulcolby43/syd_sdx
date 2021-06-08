class AuthController < ApplicationController
  def callback
    # Access the authentication hash for omniauth
    data = request.env['omniauth.auth']

    # Temporary for testing!
#    render json: data.to_json
    render json: JSON.pretty_generate(data)
  end
end
