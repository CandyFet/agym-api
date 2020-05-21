# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:valid_attributes) do
    { text: 'My comments text' }
  end

  let(:invalid_attributes) do
    { text: '' }
  end

  let(:example_post) { create :post }
  let(:example_article) { create :article }
  let(:user) { create :user }
  let(:example_post_comment) { Comment.create(commentable: example_post, user: user, text: 'some text') }
  let(:example_article_comment) { Comment.create(commentable: example_article, user: user, text: 'some text') }
  let(:access_token) { user.create_access_token }

  describe 'GET /index' do
    context 'for posts' do
      subject do
        get :index, params: {
          post_id: example_post.id
        }
      end
      it 'returns a successful response' do
        subject
        expect(response).to have_http_status(:ok)
      end
  
      it 'should return proper json' do
        example_post_comment
        subject
  
        expect(json_data.first['attributes']['header']).to eq({
                                                                'user-name' => example_post_comment.user.name,
                                                                'user-avatar-url' => example_post_comment.user.avatar_url
                                                              })
        expect(json_data.first['attributes']['body']).to eq({
                                                              'text' => example_post_comment.text
                                                            })
        expect(json_data.first['attributes']['actions']).to eq({
                                                                 'likes-total' => example_post_comment.likes.count
                                                               })
      end
  
      it 'should return comments in proper order' do
        old_comment = Comment.create(text: 'some text', user: user, commentable: example_post)
        newer_comment = Comment.create(text: 'some text', user: user, commentable: example_post)
        get :index, params: { "#{old_comment.commentable_type.downcase}_id".to_sym => old_comment.commentable_id }
        expect(json_data.first['id']).to eq(newer_comment.id.to_s)
        expect(json_data.last['id']).to eq(old_comment.id.to_s)
      end
  
      it 'should paginate results' do
        create_list :comment, 10, :for_post, commentable: example_post
        get :index, params: { post_id: example_post.id, page: 2, per_page: 1 }
        expect(json_data.length).to eq 1
        expected_comment = Comment.recent.second.id.to_s
        expect(json_data.first['id']).to eq(expected_comment)
      end
    end
    
    context 'for articles' do
      subject do
        get :index, params: {
          article_id: example_article.id
        }
      end
      it 'returns a successful response' do
        subject
        expect(response).to have_http_status(:ok)
      end
  
      it 'should return proper json' do
        example_article_comment
        subject
  
        expect(json_data.first['attributes']['header']).to eq({
                                                                'user-name' => example_article_comment.user.name,
                                                                'user-avatar-url' => example_article_comment.user.avatar_url
                                                              })
        expect(json_data.first['attributes']['body']).to eq({
                                                              'text' => example_article_comment.text
                                                            })
        expect(json_data.first['attributes']['actions']).to eq({
                                                                 'likes-total' => example_article_comment.likes.count
                                                               })
      end
  
      it 'should return comments in proper order' do
        old_comment = Comment.create(text: 'some text', user: user, commentable: example_article)
        newer_comment = Comment.create(text: 'some text', user: user, commentable: example_article)
        get :index, params: { "#{old_comment.commentable_type.downcase}_id".to_sym => old_comment.commentable_id }
        expect(json_data.first['id']).to eq(newer_comment.id.to_s)
        expect(json_data.last['id']).to eq(old_comment.id.to_s)
      end
  
      it 'should paginate results' do
        create_list :comment, 10, :for_article, commentable: example_article
        get :index, params: { article_id: example_article.id, page: 2, per_page: 1 }
        expect(json_data.length).to eq 1
        expected_comment = Comment.recent.second.id.to_s
        expect(json_data.first['id']).to eq(expected_comment)
      end
    end
  end

  describe 'GET /show' do
    context 'for posts' do
      subject { get :show, params: { post_id: example_post.id, id: example_post_comment.id } }

      it 'renders a successful response' do
        subject
        expect(response).to be_successful
      end
  
      it 'should return proper json' do
        subject
        expect(json_data['attributes']['header']).to eq({
                                                          'user-name' => example_post_comment.user.name,
                                                          'user-avatar-url' => example_post_comment.user.avatar_url
                                                              })
        expect(json_data['attributes']['body']).to eq({
                                                      'text' => example_post_comment.text
                                                            })
        expect(json_data['attributes']['actions']).to eq({
                                                        'likes-total' => example_post_comment.likes.count
                                                               })
      end
    end

    context 'for articles' do
      subject { get :show, params: { article_id: example_article.id, id: example_article_comment.id } }

      it 'renders a successful response' do
        subject
        expect(response).to be_successful
      end
  
      it 'should return proper json' do
        subject
        expect(json_data['attributes']['header']).to eq({
                                                          'user-name' => example_article_comment.user.name,
                                                          'user-avatar-url' => example_article_comment.user.avatar_url
                                                              })
        expect(json_data['attributes']['body']).to eq({
                                                      'text' => example_article_comment.text
                                                            })
        expect(json_data['attributes']['actions']).to eq({
                                                        'likes-total' => example_article_comment.likes.count
                                                               })
      end
    end
  end

  describe 'POST /create' do
    context 'when not authorized' do
      subject { post :create, params: { post_id: example_post.id } }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'for posts' do
        context 'with valid parameters' do
          it 'creates a new Comment' do
            expect { post :create, params: { post_id: example_post.id, comment: valid_attributes } }.to change(Comment, :count).by(1)
          end
  
          it 'renders a JSON response with the new comment' do
            post :create,
                 params: { post_id: example_post.id, comment: valid_attributes }
            expect(response).to have_http_status(:created)
            expect(response.content_type).to match(a_string_including('application/json'))
          end
        end
  
        context 'with invalid parameters' do
          it 'does not create a new Comment' do
            expect do
              post :create,
                   params: { post_id: example_post.id, comment: invalid_attributes }
            end.to change(Comment, :count).by(0)
          end
  
          it 'renders a JSON response with errors for the new comment' do
            post :create,
                 params: { post_id: example_post.id, comment: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
        end
      end

      context 'for articles' do
        context 'with valid parameters' do
          it 'creates a new Comment' do
            expect { post :create, params: { article_id: example_article.id, comment: valid_attributes } }.to change(Comment, :count).by(1)
          end
  
          it 'renders a JSON response with the new comment' do
            post :create,
                 params: { article_id: example_article.id, comment: valid_attributes }
            expect(response).to have_http_status(:created)
            expect(response.content_type).to match(a_string_including('application/json'))
          end
        end
  
        context 'with invalid parameters' do
          it 'does not create a new Comment' do
            expect do
              post :create,
                   params: { article_id: example_article.id, comment: invalid_attributes }
            end.to change(Comment, :count).by(0)
          end
  
          it 'renders a JSON response with errors for the new comment' do
            post :create,
                 params: { article_id: example_article.id, comment: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
        end
      end
      end
  end

  describe '#update' do
    subject { patch :update, params: { id: example_post_comment.id, comment: valid_attributes, post_id: example_post.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to update not own comment' do
      let(:other_user) { create :user }
      let(:other_comment) { example_post.comments.create!(text: 'other text', user: other_user) }
      subject { patch :update, params: { id: other_comment.id, comment: valid_attributes, post_id: example_post.id } }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        context 'for posts' do
          subject do
            patch :update, params: { id: example_post_comment.id, comment: invalid_attributes, post_id: example_post.id }
          end
  
          it 'should return 422 status code' do
            subject
            expect(response).to have_http_status(:unprocessable_entity)
          end
  
          it 'should return proper error json' do
            subject
            expect(json['errors']).to include(
              {
                'source' => { 'pointer' => '/data/attributes/text' },
                'detail' => "can't be blank"
              }
            )
          end
        end

        context 'for articles' do
          subject do
            patch :update, params: { id: example_article_comment.id, comment: invalid_attributes, post_id: example_article.id }
          end
  
          it 'should return 422 status code' do
            subject
            expect(response).to have_http_status(:unprocessable_entity)
          end
  
          it 'should return proper error json' do
            subject
            expect(json['errors']).to include(
              {
                'source' => { 'pointer' => '/data/attributes/text' },
                'detail' => "can't be blank"
              }
            )
          end
        end
      end

      context 'when success request sent' do
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        context 'for posts' do
          let(:update_attributes) do
            {
              'data' => {
                'attributes' => {
                  'header' => {
                    'user-avatar-url' => user.avatar_url,
                    'user-name' => user.name
                  },
                  'body' => {
                    'text' => 'Awesome comment'
                  },
                  'actions' => {
                    'likes-total' => example_post_comment.likes.count
                  }
                }
              }
            }
          end
  
          subject do
            patch :update, params: { id: example_post_comment.id, comment: { text: 'Awesome comment' }, post_id: example_post.id }
          end
  
          it 'should have 200 status code' do
            subject
            expect(response).to have_http_status(:ok)
          end
  
          it 'should have proper json body' do
            subject
            expect(json_data['attributes']).to include(
              update_attributes['data']['attributes']
            )
          end
  
          it 'should update the comment' do
            subject
            expect(example_post_comment.reload.text).to eq(
              update_attributes['data']['attributes']['body']['text']
            )
          end
        end

        context 'for articles' do
          let(:update_attributes) do
            {
              'data' => {
                'attributes' => {
                  'header' => {
                    'user-avatar-url' => user.avatar_url,
                    'user-name' => user.name
                  },
                  'body' => {
                    'text' => 'Awesome comment'
                  },
                  'actions' => {
                    'likes-total' => example_post_comment.likes.count
                  }
                }
              }
            }
          end
  
          subject do
            patch :update, params: { id: example_article_comment.id, comment: { text: 'Awesome comment' }, post_id: example_article.id }
          end
  
          it 'should have 200 status code' do
            subject
            expect(response).to have_http_status(:ok)
          end
  
          it 'should have proper json body' do
            subject
            expect(json_data['attributes']).to include(
              update_attributes['data']['attributes']
            )
          end
  
          it 'should update the comment' do
            subject
            expect(example_article_comment.reload.text).to eq(
              update_attributes['data']['attributes']['body']['text']
            )
          end
        end
      end
    end
  end

  describe '#destroy' do
    subject { delete :destroy, params: { id: example_post_comment.id, post_id: example_post.id, user_id: user.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to remove not own comment' do
      let(:other_user) { create :user }
      let(:other_comment) { create :comment, user: other_user }
      subject { delete :destroy, params: { id: other_comment.id, post_id: example_post.id } }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'for posts' do
        
        context 'when success request sent' do
          it 'should have 204 status code' do
            subject
            expect(response).to have_http_status(:no_content)
          end

          it 'should have proper json body' do
            subject
            expect(response.body).to be_blank
          end

          it 'should destroy the comment' do
            example_post_comment
            expect { subject }.to change { user.comments.count }.by(-1)
          end
        end
      end

      context 'for articles' do
        subject { delete :destroy, params: { id: example_article_comment.id, article_id: example_article.id, user_id: user.id } }

        context 'when success request sent' do
          it 'should have 204 status code' do
            subject
            expect(response).to have_http_status(:no_content)
          end

          it 'should have proper json body' do
            subject
            expect(response.body).to be_blank
          end

          it 'should destroy the comment' do
            example_article_comment
            expect { subject }.to change { user.comments.count }.by(-1)
          end
        end
      end
    end    
  end
end
