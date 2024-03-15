# frozen_string_literal: true

class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  skip_before_action :authorized, only: [:create]
  before_action :load_user, only: %i[update destroy]

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

  def update
    if @user.id === current_user.id
      @user.attributes = user_params
      @user.save!
      render json: 'Usuário atualizado com sucesso!'

    else
      render json: 'Você não tem permissão para atualizar esse usuário!'

    end
  end

  def destroy
    @user.destroy!
  end

  private

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    params.permit(:email, :password, :name)
  end

  def handle_invalid_record(event)
    render json: { errors: event.record.errors.full_messages }, status: :unprocessable_entity
  end
end
