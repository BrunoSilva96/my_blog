# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/posts', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  before do
    post '/auth/login', params: { email: user.email, password: user.password }
    expect(response).to have_http_status(202)
    token = JSON.parse(response.body)['token']
    headers['Authorization'] = "Bearer #{token}"
  end

  describe 'POST /posts' do
    context 'with valid params' do
      it 'create a new post' do
        post_params = FactoryBot.attributes_for(:post)

        post(posts_path, params: { post: { text: post_params[:text], user_id: user.id } }.to_json, headers:)

        expect(response).to have_http_status(201)
        expect(Post.count).to eq(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new post' do
        post_params = { text: '' }

        post(posts_path, params: { post: { text: post_params[:text], user_id: user.id } }.to_json, headers:)

        expect(response).to have_http_status(422)
        expect(Post.count).to eq(0)
      end
    end
  end

  describe 'PUT /posts/:id' do
    context 'update post' do
      it 'update post with valid params' do
        post_params = FactoryBot.attributes_for(:post)
        post(posts_path, params: { post: { text: post_params[:text], user_id: user.id } }.to_json,
                         headers:)

        post_params_update = { text: 'New texto to Post' }

        post_id = JSON.parse(response.body)['id']

        put("/posts/#{post_id}", params: { post: { text: post_params_update[:text], user_id: user.id } }.to_json,
                                 headers:)

        expect(response).to have_http_status(200)
        expect(Post.find(post_id).text).to eq('New texto to Post')
      end

      it 'update post with invalid params' do
        post_params = FactoryBot.attributes_for(:post)

        post(posts_path, params: { post: { text: post_params[:text], user_id: user.id } }.to_json,
                         headers:)

        post_params_update = { text: '' }

        post_id = JSON.parse(response.body)['id']

        put("/posts/#{post_id}", params: { post: { text: post_params_update[:text], user_id: user.id } }.to_json,
                                 headers:)

        expect(response).to have_http_status(422)
        errors = JSON.parse(response.body)
        expect(errors).to eq(["Text can't be blank"])
      end
    end

    context 'DELETE /posts/:id' do
      it 'delet post' do
        post_params = FactoryBot.attributes_for(:post)

        post(posts_path, params: { post: { text: post_params[:text], user_id: user.id } }.to_json,
                         headers:)

        post_id = JSON.parse(response.body)['id']

        delete("/posts/#{post_id}", headers:)

        expect(response).to have_http_status(200)

        expect(Post.count).to eq(0)
      end
    end
  end
end
