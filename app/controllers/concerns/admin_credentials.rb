# frozen_string_literal: true

module AdminCredentials
  extend ActiveSupport::Concern

  INVALID_CREDENTIALS_MESSAGE = "Invalid Admin & Password combination" 

  def credential_params
    params.permit(:admin_user, :password)
  end

  def verify_admin_credentials
    valid_admin_user = credential_params[:admin_user] == ENV["ADMIN_USER"]
    valid_admin_password = credential_params[:password] == ENV["ADMIN_PASSWORD"]
    
    unless valid_admin_user && valid_admin_password
      render json: { message: INVALID_CREDENTIALS_MESSAGE }, status: :unauthorized
    end
  end

  def verify_admin_token
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    begin
      @decoded_jwt = JsonWebToken.decode(header)
      @admin = @decoded_jwt[:admin]
      revoked = $redis.exists("admin:token:#{@decoded_jwt["uuid"]}:revoked")
      
      if revoked
        render json: { message: "Revoked Token is Invalid!" } , status: :unauthorized
      end

      unless @admin
        render json: { message: "Token is not Admin Invalid!" } , status: :unauthorized
      end
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end
  