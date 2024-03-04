# frozen_string_literal: true

class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  skip_before_action :authorized, only: [:create]

  def create
    user = User.create!(user_params)

    @token = encode_token(user_id: user.id)

    render json: {
      user: UserSerializer.new(user),
      token: @token
    }, status: :created
  end

  def person
    render json: current_user, status: :ok
  end

  private

  def user_params
    params.permit(:email, :password, :name)
  end

  def handle_invalid_record(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
end
