# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/comments', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  before do
    post '/auth/login', params: { email: user.email, password: user.password }
    expect(response).to have_http_status(202)
    token = JSON.parse(response.body)['token']
    headers['Authorization'] = "Bearer #{token}"

    post_params = FactoryBot.attributes_for(:post)

    @create_post = post(posts_path, params: { post: { text: post_params[:text], user_id: user.id } }.to_json, headers:)
    @id_post = JSON.parse(response.body)['id']
  end

  describe 'POST /comments' do
    context 'with valid params' do
      it 'create a new comment' do
        comment_params = FactoryBot.attributes_for(:comment)

        post(comments_path,
             params: { comment: { text: comment_params[:text], user_id: user.id, post_id: @id_post } }.to_json, headers:)

        expect(response).to have_http_status(201)
        expect(Comment.count).to eq(1)
      end

      it 'does not create a new comment' do
        comment_params = { text: '' }

        post(comments_path,
             params: { comment: { text: comment_params[:text], user_id: user.id, post_id: @id_post } }.to_json, headers:)

        expect(response).to have_http_status(422)
        expect(Comment.count).to eq(0)
      end
    end
  end

  describe 'PUT /coments/:id' do
    context 'update comments' do
      it 'update comment with valid params' do
        comment_params = FactoryBot.attributes_for(:comment)
        post(comments_path,
             params: { comment: { text: comment_params[:text], user_id: user.id, post_id: @id_post } }.to_json, headers:)

        comment_params_update = 'New comment after update'

        comment_id = JSON.parse(response.body)['id']

        put("/comments/#{comment_id}",
            params: { comment: { text: comment_params_update, user_id: user.id, post_id: @id_post } }.to_json, headers:)

        expect(response).to have_http_status(200)
        expect(Comment.find(comment_id).text).to eq('New comment after update')
      end
    end
  end
end
