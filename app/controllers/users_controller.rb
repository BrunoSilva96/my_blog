class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.valid?
      @user.save
      @payload = { user: @user.id }
      @token = JWT.encode(@payload, 'okcool', 'HS256')
      render json: { user: @user, token: @token }
    else
      render json: @user.errors.full_messages
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password_digest)
  end
end
