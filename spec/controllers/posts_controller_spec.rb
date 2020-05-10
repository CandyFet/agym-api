# frozen_string_literal: true

require 'rails_helper'

describe PostsController do
  describe '#index' do
    subject { get :index }
    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      create_list :post, 10
      subject
      Post.recent.each_with_index do |post, index|
        expect(json_data[index]['attributes']).to eq({
                                                       'title' => post.title,
                                                       'text' => post.text,
                                                       'slug' => post.slug,
                                                       'preview-text' => post.preview_text
                                                     })
      end
    end

    it 'should return posts in proper order' do
      old_post = create :post
      newer_post = create :post
      subject
      expect(json_data.first['id']).to eq(newer_post.id.to_s)
      expect(json_data.last['id']).to eq(old_post.id.to_s)
    end

    it 'should paginate results' do
      create_list :post, 10
      get :index, params: { page: 2, per_page: 1 }
      expect(json_data.length).to eq 1
      expected_post = Post.recent.second.id.to_s
      expect(json_data.first['id']).to eq(expected_post)
    end
  end

  describe '#show' do
    let(:post) { create :post }
    subject { get :show, params: { id: post.id } }

    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      subject
      post.reload
      expect(json_data['attributes']).to eq({
                                              'title' => post.title,
                                              'text' => post.text,
                                              'slug' => post.slug,
                                              'preview-text' => post.preview_text
                                            })
    end
  end

  describe '#create' do
    subject { post :create }

    context 'when no code is provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code is provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized request' do
      let(:access_token) { create :access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                text: ''
              }
            }
          }
        end
        subject { post :create, params: invalid_attributes }

        it 'should return 422 status code' do
          subject

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject

          expect(json['errors']).to include(
            {
              'source' => { 'pointer' => '/data/attributes/title' },
              'detail' => "can't be blank"
            },
            {
              'source' => { 'pointer' => '/data/attributes/text' },
              'detail' => "can't be blank"
            }

          )
        end
      end

      context 'when success request sent' do
        let(:access_token) { create :access_token }
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'title' => 'Awesome post',
                'text' => 'Super text',
                'slug' => 'awesome-post'
              }
            }
          }
        end

        subject { post :create, params: valid_attributes }

        it 'should have 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should have proper json body' do
          subject
          expect(json_data['attributes']).to include(
            valid_attributes['data']['attributes']
          )
        end

        it 'should create the post' do
          expect { subject }.to change { Post.count }.by(1)
        end
      end
    end
  end

  describe '#update' do
    let(:user) { create :user }
    let(:post) { create :post, user: user }
    let(:access_token) { user.create_access_token }

    subject { patch :update, params: { id: post.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to update not own post' do
      let(:other_user) { create :user }
      let(:other_post) { create :post, user: other_user }
      subject { patch :update, params: { id: other_post.id } }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                text: ''
              }
            }
          }
        end

        subject do
          patch :update, params: invalid_attributes.merge(id: post.id)
        end

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json['errors']).to include(
            {
              'source' => { 'pointer' => '/data/attributes/title' },
              'detail' => "can't be blank"
            },
            {
              'source' => { 'pointer' => '/data/attributes/text' },
              'detail' => "can't be blank"
            }
          )
        end
      end

      context 'when success request sent' do
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'title' => 'Awesome post',
                'text' => 'Super content',
                'slug' => post.reload.slug
              }
            }
          }
        end

        subject do
          patch :update, params: valid_attributes.merge(id: post.id)
        end

        it 'should have 200 status code' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'should have proper json body' do
          subject
          expect(json_data['attributes']).to include(
            valid_attributes['data']['attributes']
          )
        end

        it 'should update the post' do
          subject
          expect(post.reload.title).to eq(
            valid_attributes['data']['attributes']['title']
          )
        end
      end
    end
  end

  describe '#destroy' do
    let(:user) { create :user }
    let(:post) { create :post, user: user }
    let(:access_token) { user.create_access_token }

    subject { delete :destroy, params: { id: post.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to remove not own post' do
      let(:other_user) { create :user }
      let(:other_post) { create :post, user: other_user }
      subject { delete :destroy, params: { id: other_post.id } }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
      end

      context 'when success request sent' do

        it 'should have 204 status code' do
          subject
          expect(response).to have_http_status(:no_content)
        end

        it 'should have proper json body' do
          subject
          expect(response.body).to be_blank
        end

        it 'should destroy the post' do
          post
          expect { subject }.to change{ user.posts.count }.by(-1)
        end
      end
    end
  end
end
