require 'rails_helper'

RSpec.describe '/users', type: :request do
  let(:login_user) { create(:user) }

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

  describe 'PUT /users/:id' do
    let(:user) { create(:user) }

    it 'Update logged user' do
      post '/auth/login', params: { email: user.email, password: user.password }
      expect(response).to have_http_status(202)
      token = JSON.parse(response.body)['token']

      new_attributes = { name: 'UserNewName' }

      headers = { 'Authorization': "Bearer #{token}", 'Content-Type': 'application/json',
                  'Accept': 'application/json' }

      put("/users/#{user.id}", params: new_attributes.to_json, headers:)

      expect(response).to have_http_status(200)
      expect(user.reload.name).to eq('UserNewName')
    end

    it 'Invalid params to update user' do
      post '/auth/login', params: { email: user.email, password: user.password }
      expect(response).to have_http_status(202)
      token = JSON.parse(response.body)['token']

      invalid_attributes = { name: '' }

      headers = { 'Authorization': "Bearer #{token}", 'Content-Type': 'application/json',
                  'Accept': 'application/json' }

      put("/users/#{user.id}", params: invalid_attributes.to_json, headers:)

      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)).to include('errors')
    end
  end

  context 'DELETE /users/:id'
  let(:user) { create(:user) }
  it 'Delete user logged' do
    post '/auth/login', params: { email: user.email, password: user.password }
    expect(response).to have_http_status(202)
    token = JSON.parse(response.body)['token']

    headers = { 'Authorization': "Bearer #{token}", 'Content-Type': 'application/json', 'Accept': 'application/json' }

    delete("/users/#{user.id}", headers:)

    expect(response).to have_http_status(204)

    expect(User.exists?(user.id)).to be_falsey
  end
end
