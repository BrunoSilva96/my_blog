# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[update destroy]
  before_action :load_post, only: %i[destroy]

  def create
    @comment = Comment.new(comment_params.merge(user_id: current_user&.id))

    if @comment.save
      render json: {
        id: @comment.id,
        Comment: @comment
      }, status: :created
    else
      render json: { error: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @comment.user_id === current_user.id
      @comment.attributes = comment_params
      @comment.save!

      render json: 'Comentário atualizado com sucesso!'
    else
      render json: 'Você não tem permissão para atualizar esse comentário.'
    end
  end

  def destroy
    if @comment.user_id === current_user.id || @current_post.user_id === current_user.id

      @comment.destroy!
      render json: 'Comentário deletado com sucesso!'
    else
      render json: 'Você não tem permissão para deletar esse comentário.'
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
    return if @comment

    render json: { error: 'Comentário não encontrado' }, status: :not_found
  end

  def load_post
    @current_post = Post.find(@comment.post_id)
    return if @current_post

    render json: { error: 'Post não encontrado' }, status: :not_found
  end

  def comment_params
    params.require(:comment).permit(:text, :post_id)
  end
end
