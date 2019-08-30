class SeedsController < ApplicationController

  def plant
    Rails.application.load_seed

    render json: { message: "Seeded" }, status: :ok
  end
end