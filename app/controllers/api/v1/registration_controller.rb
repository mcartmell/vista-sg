class Api::V1::RegistrationController < ApplicationController
  respond_to :json
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!, :only => [:create, :login]

  def create
    user = User.new(email: params[:email], password: params[:password])
    if user.save
      render :json=>
        user.as_json.merge(:auth_token=>user.authentication_token, :email=>user.email), :status=>201
      return
    else
      warden.custom_failure!
      render :json=> user.errors, :status=>422
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user.valid_password?(params[:password])
      puts 111
      render json: {
        auth_token: user.authentication_token
      }
    else 
      warden.custom_failure!
      render :json => {
        error: "Bad password"
      }, :status=>403
    end
  end
end
