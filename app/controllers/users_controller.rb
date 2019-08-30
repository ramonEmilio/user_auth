class UsersController < ApplicationController
  include UserCredentials

  before_action :verify_user_token, only: [:show]

  def create
    if user.save
      render json: user.to_json, status: :created
    else
      render json: user.errors.messages, status: :unprocessable_entity
    end
  end

  def show
    render json: user.to_json, status: :ok
  end
end
