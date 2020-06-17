# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#index' do
    subject { get :index }
    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code is provided' do
      before { request.headers['authorization'] = 'Bearer invalid code' }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }

      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it 'should have success response' do
         subject

         expect(response).to have_http_status(:ok)
      end

      it 'should return proper json' do
        create_list :user, 5
        subject
        
        User.all.each_with_index do |user, index|
          expect(json_data[index]['attributes']['header']).to eq(
            {
              'name' => user.name,
              'avatar-url' => user.avatar_url,
              'login' => user.login,
              'admin' => user.admin?,
              'ambassador' => user.ambassador?,
              'trainer' => user.trainer?
            }
          )
          expect(json_data[index]['attributes']['body']).to eq(
            {
              
            }
          )
          expect(json_data[index]['attributes']['actions']).to eq(
            {
              
            }
          )
        end
      end

      it 'should paginate results' do
        create_list :user, 5
        get :index, params: { page: 2, per_page: 1 }
        expect(json_data.length).to eq 1
        expected_user = User.all.second.id.to_s
        expect(json_data.first['id']).to eq(expected_user)
      end
    end 
  end

  describe '#show' do
    let(:user) { create :user }
    subject { get :show, params: { id: user.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code is provided' do
      before { request.headers['authorization'] = 'Bearer invalid code' }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:other_user) { create :user }
      let(:access_token) { user.create_access_token }

      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      subject { get :show, params: { id: other_user.id } }

      it 'should return success response' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'should have proper json' do
        subject

        expect(json_data['attributes']['header']).to eq(
          {
            'name' => other_user.name,
            'avatar-url' => other_user.avatar_url,
            'login' => other_user.login,
            'admin' => other_user.admin?,
            'ambassador' => other_user.ambassador?,
            'trainer' => other_user.trainer?
          }
        )
        expect(json_data['attributes']['body']).to eq(
          {
            
          }
        )
        expect(json_data['attributes']['actions']).to eq(
          {
            
          }
        )
      end
    end
  end

  describe '#update' do
    let(:user) { create :user }
    let(:other_user) { create :user }
    let(:access_token) { user.create_access_token }
    let(:invalid_attributes) do
      {
        data: {
          attributes: {
            header: {
              name: '',
              avatar_url: '',
              login: '',
              password: '',
              admin: '',
              ambassador: '',
              trainer: '',
              provider: ''
            }
          }
        }
      }
    end

    let(:valid_attributes) do
      {
        'data' => {
          'attributes' =>  {
            'header' =>  {
              'name' => 'John Doe',
              'login' => 'JohnyDoe',
              'password' => 'qwerty123',
              'admin' => 'false',
              'ambassador' => 'false',
              'trainer' => 'false'
            }
          }
        }
      }
    end

    subject { patch :update, params: { id: user.id } }

    context 'when no code is provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code is provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized as user' do
      
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do

        subject do
          patch :update, params: invalid_attributes.merge(id: user.id)
        end

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json['errors']).to include(
            {
              'source' => { 'pointer' => '/data/attributes/login' },
              'detail' => "can't be blank"
            }
          )
        end
      end

      context 'when success request sent' do

        subject do
          patch :update, params: valid_attributes.merge(id: user.id)
        end

        it 'should have 200 status code' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'should have proper json body' do
          subject
          expect(json_data['attributes']['header']).to eq(
            {
              'name' => 'John Doe',
              'login' => 'JohnyDoe',
              'admin' => false,
              'ambassador' => false,
              'trainer' => false,
              'avatar-url' => user.avatar_url
            }
          )
        end

        it 'should update the current user' do
          subject
          expect(user.reload.name).to eq(
            valid_attributes['data']['attributes']['header']['name']
          )
        end
      end

      context 'when trying to update different user' do
        subject { patch :update, params: { id: other_user.id } }

        before { request.headers['authorization'] = "Bearer #{access_token.token}" }
        it_behaves_like 'forbidden_requests'
      end
    end

    context 'when authorized as admin' do
      let(:admin) { create :user, admin: true }
      let(:admin_access_token) { admin.create_access_token }
      before { request.headers['authorization'] = "Bearer #{admin_access_token.token}" }

      context 'when invalid parameters provided' do

        subject do
          patch :update, params: invalid_attributes.merge(id: user.id)
        end

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json['errors']).to include(
            {
              'source' => { 'pointer' => '/data/attributes/login' },
              'detail' => "can't be blank"
            }
          )
        end
      end

      context 'when success request sent' do

        subject do
          patch :update, params: valid_attributes.merge(id: user.id)
        end

        it 'should have 200 status code' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'should have proper json body' do
          subject
          expect(json_data['attributes']['header']).to eq(
            {
              'name' => 'John Doe',
              'login' => 'JohnyDoe',
              'admin' => false,
              'ambassador' => false,
              'trainer' => false,
              'avatar-url' => user.avatar_url
            }
          )
        end

        it 'should update the user' do
          subject
          expect(user.reload.name).to eq(
            valid_attributes['data']['attributes']['header']['name']
          )
        end
      end
    end
  end

  describe '#destroy' do
    let(:user) { create :user }
    let(:other_user) { create :user }
    let(:access_token) { user.create_access_token }

    subject { delete :destroy, params: { id: user.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = "Bearer invalid" }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized as user' do
      # TODO: Make it work
      # context 'when trying to delete different user' do
      #   subject { delete :destroy, params:{ id: other_user.id } }
  
      #   before { request.headers['authorization'] = "Bearer #{access_token.token}" }
  
      #   it_behaves_like 'forbidden_requests'
      # end

      context 'when success request sent' do
        
        subject { delete :destroy, params: { id: user.id } }

        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        it 'should have 204 status code' do
          subject
          expect(response).to have_http_status(:no_content)
        end

        it 'should have proper json body' do
          subject
          expect(response.body).to be_blank
        end

        it 'should destroy the user' do
          user
          expect { subject }.to change { User.all.size }.by(-1)
        end
      end
    end

    context 'when authorized as admin' do
      let(:admin) { create :user, admin: true }
      let(:admin_access_token) { admin.create_access_token }

      before { request.headers['authorization'] = "Bearer #{admin_access_token.token}" }

      context 'when deleting other user' do
        it 'should have 204 status code' do
          subject
          expect(response).to have_http_status(:no_content)
        end

        it 'should have proper json body' do
          subject
          expect(response.body).to be_blank
        end

        it 'should destroy the user' do
          user
          expect { subject }.to change { User.all.size }.by(-1)
        end
      end
    end

  end
end
