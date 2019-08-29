class TokensController < ApplicationController
  before_action
  
  def create
  end

  def authenticate
  end

  def delete
  end

  private

  def user_params
    params.fetch(:user, {}).permit(:username, :password)
  end
end
