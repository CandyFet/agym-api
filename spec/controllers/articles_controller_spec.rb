# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe '#index' do
    subject { get :index }
    it 'should have success status response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      create_list :article, 10
      subject
      Article.recent.each_with_index do |article, index|
        expect(json_data[index]['attributes']['header']).to eq(
          {
            'title' => article.title,
            'user-name' => article.user.name,
            'slug' => article.slug,
            'user-avatar-url' => article.user.avatar_url
          }
        )
        expect(json_data[index]['attributes']['body']).to eq(
          {
            'text' => article.text,
            'preview-text' => article.preview_text
          }
        )
        expect(json_data[index]['attributes']['actions']).to eq(
          {
            'likes-total' => article.likes.count,
            'reposts-total' => article.reposts.count,
            'comments-total' => article.comments.count
          }
        )
      end
    end

    it 'should return articles in proper order' do
      old_article = create :article
      newer_article = create :article
      
      subject

      expect(json_data.first['id']).to eq(newer_article.id.to_s)
      expect(json_data.last['id']).to eq(old_article.id.to_s)
    end

    it 'should paginate results' do
      create_list :article, 10
      get :index, params: { page: 2, per_page: 1 }
      expect(json_data.length).to eq 1
      expected_article = Article.recent.second.id.to_s
      expect(json_data.first['id']).to eq(expected_article)
    end
  end

  describe '#show' do
    let(:article) { create :article }
    subject { get :show, params: { id: article.id } }

    it 'should have success status response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      subject

      article.reload

      expect(json_data['attributes']['header']).to eq(
        {
          'title' => article.title,
          'user-name' => article.user.name,
          'slug' => article.slug,
          'user-avatar-url' => article.user.avatar_url
        }
      )
      expect(json_data['attributes']['body']).to eq(
        {
          'text' => article.text,
          'preview-text' => article.preview_text
        }
      )
      expect(json_data['attributes']['actions']).to eq(
        {
          'likes-total' => article.likes.count,
          'reposts-total' => article.reposts.count,
          'comments-total' => article.comments.count
        }
      )
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
                header: {
                  title: ''
                },
                body: {
                  text: ''
                }
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
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'header' => {
                  'title' => 'some title',
                  'slug' => 'some-title',
                  'user-avatar-url' => nil,
                  'user-name' => nil
                },
                'body' => {
                  'text' => 'some text',
                  'preview-text' => 'some text'
                },
                'actions' => {
                  'comments-total' => 0,
                  'likes-total' => 0,
                  'reposts-total' => 0
                }
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

        it 'should create the article' do
          expect { subject }.to change { Article.count }.by(1)
        end
      end
    end
  end

  describe '#update' do
    let(:user) { create :user }
    let(:article) { create :article, user: user }
    let(:access_token) { user.create_access_token }

    subject { patch :update, params: { id: article.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to update not own article' do
      let(:other_user) { create :user }
      let(:other_article) { create :article, user: other_user }
      subject { patch :update, params: { id: other_article.id } }
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
                header: {
                  title: ''
                },
                body: {
                  text: ''
                }
              }
            }
          }
        end

        subject do
          patch :update, params: invalid_attributes.merge(id: article.id)
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
              'attributes' =>  {
                'header' =>  {
                  'title' => article.title,
                  'user-name' => article.user.name,
                  'slug' => article.title.parameterize,
                  'user-avatar-url' => article.user.avatar_url
                },
                'body' =>  {
                  'text' => article.text,
                  'preview-text' => article.preview_text
                },
                'actions' => {
                  'likes-total' => article.likes.count,
                  'reposts-total' => article.reposts.count,
                  'comments-total' => article.comments.count
                }
              }
            }
          }
        end

        subject do
          patch :update, params: valid_attributes.merge(id: article.id)
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

        it 'should update the article' do
          subject
          expect(article.reload.title).to eq(
            valid_attributes['data']['attributes']['header']['title']
          )
        end
      end
    end
  end

  describe '#delete' do
    let(:user) { create :user }
    let(:article) { create :article, user: user }
    let(:access_token) { user.create_access_token }

    subject { delete :destroy, params: { id: article.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to remove not own article' do
      let(:other_user) { create :user }
      let(:other_article) { create :article, user: other_user }
      subject { delete :destroy, params: { id: other_article.id } }
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

        it 'should destroy the article' do
          article
          expect { subject }.to change { user.articles.count }.by(-1)
        end
      end
    end
  end
end
