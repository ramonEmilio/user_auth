class CredentialsController < ApplicationController
  include UserCredentials

  before_action :verify_user_credentials, only: [:verfy]

  def verify
    render json: { message: "Valid Credentials" }, status: :ok
  end
end