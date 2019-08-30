class SessionsController < ApplicationController
  include UserCredentials

  before_action :verify_user_credentials, only: [:create]
  before_action :verify_user_token, only: [:destroy]
  
  def create
    uuid = SecureRandom.uuid
    time = Time.current + 24.hours
    payload = { username: @user.username, uuid: uuid }
    token = JsonWebToken.encode(payload, time)
    @user.save_token(uuid, time)
    
    render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                    username: @user.username }, status: :ok
  end

  def destroy
    token_revoke_key = "token:#{@decoded_jwt["uuid"]}:revoked"
    expire_at = Time.current + 24.hours
    
    $redis.multi do
      $redis.set(token_revoke_key, true)
      $redis.expireat(token_revoke_key, expire_at.to_i)
    end
    
    render nil, status: :no_content
  end

end
