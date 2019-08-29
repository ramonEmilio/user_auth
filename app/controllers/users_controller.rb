class UsersController < ApplicationController
  def create
    @user = User.new(
      username: user_params[:username], 
      password: user_params[:password]
    )

    if @user.save
      render json: @user.to_json, status: :created
    else
      render json: @user.errors.messages, status: :unprocessable_entity
    end
  end

  def authenticate
    @user = User.new(
      username: authenticate_params[:username], 
      password: authenticate_params[:password]
    )

    if @user.authenticate
      render json:{}, status: :ok
    else
      render json: {}, status: :unauthorized
    end
  end

  private

  def user_params
    params.fetch(:user, {}).permit(:username, :password)
  end
  
  def authenticate_params
    params.permit(:username, :password)
  end
end
