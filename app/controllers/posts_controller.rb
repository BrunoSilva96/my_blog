class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]

  def index
    @posts = Post.all
    render json: @posts
  end

  def show
    return unless @post.comment

    render json: { post: @post, comment: @post.comment }
  end

  def create
    @post = Post.new(post_params)

    return unless @post.save

    render json: @post
  end

  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: 'Erro na atualização', status: 500
    end
  end

  def destroy
    @post.destroy

    render json: 'Post deletado com sucesso!'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:post_text)
  end
end
