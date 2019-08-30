class Admin::UsersController < ApplicationController
  include AdminCredentials

  before_action :verify_admin_token

  def index
    @users = $redis.smembers("usernames")

    render json: @users, staus: :ok
  end

  def show
    @user = User.new(user_params[:username])
    
    render json: @user.to_json, status: :ok
  end

  def logout
    uuid = logout_params[:token_uuid]
    token_revoke_key = "token:#{uuid}:revoked"
    expire_at = Time.current + 24.hours
    
    $redis.multi do
      $redis.set(token_revoke_key, true)
      $redis.expireat(token_revoke_key, expire_at.to_i)
    end
    
    render json: {message: "Token Revoked"}, status: :no_content
  end

  private

  def user_params
    params.permit(:username)
  end

  def logout_params
    params.permit(:username, :token_uuid)
  end
end