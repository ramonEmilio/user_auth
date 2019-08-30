# frozen_string_literal: true

module UserCredentials
  extend ActiveSupport::Concern

  INVALID_CREDENTIALS_MESSAGE = "Username & Password combination" 

  def user
    @user ||= User.new(params[:username], params[:password])
  end

  def credential_params
    params.fetch(:credentials, {}).permit(:username, :password)
  end

  def verify_user_credentials
    unless user.verify_credentials
      render json: { message: INVALID_CREDENTIALS_MESSAGE }, status: :unauthorized
    end
  end

  def verify_user_token
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    begin
      @decoded_jwt = JsonWebToken.decode(header)
      @user = User.new(@decoded_jwt[:username])
      revoked = $redis.exists("token:#{@decoded_jwt['uuid']}:revoked")
      
      if revoked
        render json: { message: "Revoked Token is Invalid!" } , status: :unauthorized
      end

      unless @user.exists
        render json: { message: "User is Invalid!" } , status: :unauthorized
      end
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end
  