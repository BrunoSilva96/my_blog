# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users', type: :request do
  describe 'POST /users' do
    context 'with valid params' do
      it 'creates a new user' do
        user_params = FactoryBot.attributes_for(:user)
        post users_path, params: { user: user_params }

        expect(response).to have_http_status(201)
        expect(User.count).to eq(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new user' do
        user_params = { username: '', email: '', password: '' }
        post '/users', params: { user: user_params }

        expect(response).to have_http_status(422)
        expect(User.count).to eq(0)
      end
    end
  end

  describe 'Only authenticated' do
    let!(:user) { create(:user) }
    let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

    before do
      post '/auth/login', params: { email: user.email, password: user.password }
      expect(response).to have_http_status(202)
      token = JSON.parse(response.body)['token']
      headers['Authorization'] = "Bearer #{token}"
    end
    context 'PUT /user/:id' do
      it 'Update logged user' do
        new_attributes = { name: 'UserNewName' }

        put("/users/#{user.id}", params: new_attributes.to_json, headers:)

        expect(response).to have_http_status(200)
        expect(user.reload.name).to eq('UserNewName')
      end

      it 'Invalid params to update user' do
        invalid_attributes = { name: '' }

        put("/users/#{user.id}", params: invalid_attributes.to_json, headers:)

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)).to include('errors')
      end

      context 'DELETE /users/:id' do
        it 'Delete user logged' do
          delete("/users/#{user.id}", headers:)

          expect(response).to have_http_status(204)
          expect(User.exists?(user.id)).to be_falsey
        end
      end
    end

    describe 'unauthenticated user' do
      context 'user unauthorized' do
        it 'trying to update another user' do
          user_params_2 = FactoryBot.attributes_for(:user)

          post users_path, params: { user: user_params_2 }
          user_id = JSON.parse(response.body)['id']
          expect(response).to have_http_status(201)

          unauthorized_attributes = 'NewNameUnauthorized'

          put("/users/#{user_id}", params: unauthorized_attributes.to_json, headers:)

          expect(response).to have_http_status(401)
        end

        it 'trying to delete another user' do
          user_params_2 = FactoryBot.attributes_for(:user)

          post users_path, params: { user: user_params_2 }
          user_id = JSON.parse(response.body)['id']
          expect(response).to have_http_status(201)

          delete("/users/#{user_id}", headers:)

          expect(response).to have_http_status(401)
          expect(User.exists?(user.id)).to be_truthy
        end
      end
    end
  end
end
