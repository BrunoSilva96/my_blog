class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)

    return unless @comment.save

    render json: @comment
  end

  private

  def comment_params
    params.require(:comment).permit(:comment_text, :post_id)
  end
end
