class Admin::SessionsController < ApplicationController
  include AdminCredentials

  before_action :verify_admin_credentials, only: [:create]
  before_action :verify_admin_token, only: [:destroy]
  
  def create
    uuid = SecureRandom.uuid
    time = Time.current + 24.hours
    payload = { uuid: uuid, admin: true }
    token = JsonWebToken.encode(payload, time)
    token_key = "admin:token:#{uuid}"
    
    $redis.multi do
      $redis.set(token_key, time.to_i)
      $redis.expireat(token_key, time.to_i)
    end
    
    render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                    admin: true }, status: :ok
  end

  def destroy
    token_revoke_key = "admin:token:#{@decoded_jwt["uuid"]}:revoked"
    expire_at = Time.current + 24.hours
    
    $redis.multi do
      $redis.set(token_revoke_key, true)
      $redis.expireat(token_revoke_key, expire_at.to_i)
    end
    
    render nil, status: :no_content
  end

end