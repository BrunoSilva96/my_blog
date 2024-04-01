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

      context 'with invalid params' do
        it 'does not create a new comment' do
          comment_params = { text: '' }

          post(comments_path,
               params: { comment: { text: comment_params[:text], user_id: user.id, post_id: @id_post } }.to_json, headers:)

          expect(response).to have_http_status(422)
          expect(Comment.count).to eq(0)
        end
      end
    end
  end

  describe 'PUT /comments/:id' do
    context 'update comments with valid params' do
      it 'update comment' do
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

    context 'update comments with invalid params' do
      it 'does not update comment' do
        comment_params = FactoryBot.attributes_for(:comment)
        post(comments_path,
             params: { comment: { text: comment_params[:text], user_id: user.id, post_id: @id_post } }.to_json, headers:)

        comment_params_update = ''
        comment_id = JSON.parse(response.body)['id']

        put("/comments/#{comment_id}",
            params: { comment: { text: comment_params_update, user_id: user.id, post_id: @id_post } }.to_json, headers:)

        expect(response).to have_http_status(422)
        errors = JSON.parse(response.body)
        expect(errors).to eq(["Text can't be blank"])
      end
    end
  end

  describe 'DELETE /comment/:id' do
    it 'delete comment' do
      comment_params = FactoryBot.attributes_for(:comment)

      post(comments_path, params: { comment: { text: comment_params[:text], user_id: user.id, post_id: @id_post } }.to_json,
                          headers:)

      comment_id = JSON.parse(response.body)['id']

      delete("/comments/#{comment_id}", headers:)

      expect(response).to have_http_status(200)
      expect(Comment.count).to eq(0)
    end
  end
end
