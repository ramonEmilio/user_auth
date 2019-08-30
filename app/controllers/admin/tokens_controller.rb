class Admin::TokensController < ApplicationController
  include AdminCredentials

  before_action :verify_admin_token

  def index
    render json: { all: user_tokens, revoked: revoked_user_tokens}, status: :ok
  end

  def user_tokens
    result = []
    $redis.scan_each(match: "user:*:token:*") { |key| result << key }
    result
  end

  def revoked_user_tokens
    result = []
    $redis.scan_each(match: "token:*:revoked") { |key| result << key }
    result
  end

end