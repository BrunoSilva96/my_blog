# frozen_string_literal: true

class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params.merge(user_id: current_user&.id))

    return unless @comment.save

    render json: @comment
  end

  private

  def comment_params
    params.require(:comment).permit(:text, :post_id)
  end
end
