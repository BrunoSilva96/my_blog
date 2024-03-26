# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]

  def index
    @posts = Post.includes(:comments, :user).order(created_at: :desc)

    render json: {
      Posts: @posts.map { |post| format_post_for_show(post) }

    }, status: :created
  end

  def show
    return unless @post

    render json: {
      Post: format_comments_for_post(@post)
    }
  end

  def create
    @post = Post.new(post_params.merge(user_id: current_user&.id))

    if @post.save
      render json: {
        id: @post.id,
        Author: current_user.name,
        Post: PostSerializer.new(@post)
      }, status: :created
    else
      render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @post.user_id === current_user.id
      @post.attributes = post_params
      @post.save!
      render json: 'Post atualizado com sucesso!'
    else
      render json: 'Você não tem permissão para atualizar esse post!'
    end
  end

  def destroy
    if @post.user_id === current_user.id
      @post.destroy!
      render json: 'Post deletado com sucesso!'
    else
      render json: 'Você não tem permissão para deletar esse post!'
    end
  end

  private

  def set_post
    @post = Post.find_by_id(params[:id])
    return if @post

    render json: { error: 'Post não encontrado' }, status: :not_found
  end

  def post_params
    params.require(:post).permit(:text)
  end

  def format_post_for_show(post)
    {
      id: post.id,
      author: post.user.name,
      text: post.text,
      comments: post.comments.count
    }
  end

  def format_comments_for_post(post)
    {
      author: post.user.name,
      text: post.text,
      comments: post.comments.map { |comment| format_comment(comment) }
    }
  end

  def format_comment(comment)
    {
      author: comment.user.name,
      coment: comment.text
    }
  end
end
