# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[update destroy]

  def create
    @comment = Comment.new(comment_params.merge(user_id: current_user&.id))

    return unless @comment.save

    render json: @comment
  end

  def update
    @comment.attributes = comment_params
    @comment.save!

    render json: 'Comentário atualizado com sucesso!'
  end

  def destroy
    if @comment.user_id === current_user.id
      @comment.destroy!
      render json: 'Comentário deletado com sucesso!'
    else
      render json: 'Você não tem permissão para deletar esse comentário.'
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:text, :post_id)
  end
end
