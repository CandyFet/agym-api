# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LikesController, type: :controller do
  let(:example_post) { create :post }
  let(:user) { create :user }
  let(:example_comment) { example_post.comments.create(text: 'test text', user: user) }
  let(:comment_like) { Like.create(user: user, likeble: example_comment) }
  let(:post_like) { Like.create(user: user, likeble: example_post) }
  let(:access_token) { user.create_access_token }

  describe '#index' do
    context 'for posts' do
      subject { get :index, params: { post_id: example_post.id } }
      it 'should return success response' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'should return proper json' do
        post_like
        subject
        expect(json_data.first['attributes']).not_to be_blank
      end
    end
    context 'for comments' do
      subject { get :index, params: { post_id: example_post.id, comment_id: example_comment.id } }
      it 'should return success response' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'should return proper json' do
        comment_like
        subject
        expect(json_data.first['attributes']).not_to be_blank
      end
    end
  end

  describe 'POST /create' do
    context 'for posts' do
      subject do
        post :create, params: { post_id: example_post.id, like: { likeble_id: example_post.id,
                                                                  likeble_type: 'Post' } }
      end

      context 'when not authorized' do
        it_behaves_like 'forbidden_requests'
      end

      context 'when authorized' do     
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        context 'with valid parameters' do
          it 'creates a new like' do
            expect { subject }.to change(Like, :count).by(1)
          end

          it 'renders a JSON response with the new like' do
            subject
            expect(response).to have_http_status(:created)
            expect(response.content_type).to match(a_string_including('application/json'))
          end
        end

        context 'with invalid parameters' do
          it 'does not create a new like' do
            expect do
              post :create, params: { post_id: example_post.id, like: {
                likeble_id: nil,
                likeble_type: nil
              } }
            end.to change(Like, :count).by(0)
          end

          it 'renders a JSON response with errors for the new like' do
            post :create, params: { post_id: example_post.id, like: {
              likeble_id: nil,
              likeble_type: nil
            } }
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
        end
      end
    end

    context 'for comments' do
      subject do
        post :create, params: { post_id: example_post.id, comment_id: example_comment.id, like: {
          likeble_id: example_comment.id,
          likeble_type: 'Comment'
        } }
      end
      context 'when not authorized' do
        it_behaves_like 'forbidden_requests'
      end

      context 'when authorized' do
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        context 'with valid parameters' do
          it 'creates a new like' do
            expect { subject }.to change(Like, :count).by(1)
          end

          it 'renders a JSON response with the new comment' do
            subject
            expect(response).to have_http_status(:created)
            expect(response.content_type).to match(a_string_including('application/json'))
          end
        end

        context 'with invalid parameters' do
          it 'does not create a new like' do
            expect do
              post :create, params: { post_id: example_post.id, comment_id: example_comment.id, like: {
                likeble_id: nil,
                likeble_type: nil
              } }
            end.to change(Like, :count).by(0)
          end

          it 'renders a JSON response with errors for the new comment' do
            post :create, params: { post_id: example_post.id, comment_id: example_comment.id, like: {
              likeble_id: nil,
              likeble_type: nil
            } }
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
        end
      end
    end
  end

  describe '#destroy' do
    context 'for posts' do
      subject { delete :destroy, params: { id: post_like.id, post_id: example_post.id, user_id: user.id } }

      context 'when no code provided' do
        it_behaves_like 'forbidden_requests'
      end

      context 'when invalid code provided' do
        before { request.headers['authorization'] = 'Invalid token' }
        it_behaves_like 'forbidden_requests'
      end

      context 'when trying to remove not own like' do
        let(:other_user) { create :user }
        let(:other_like) { Like.create(user: other_user, likeble: example_post) }
        subject { delete :destroy, params: { id: other_like.id, post_id: example_post.id } }
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        it_behaves_like 'forbidden_requests'
      end

      context 'when authorized' do
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        context 'when success request sent' do
          it 'should have 204 status code' do
            subject
            expect(response).to have_http_status(:no_content)
          end

          it 'should have proper json body' do
            subject
            expect(response.body).to be_blank
          end

          it 'should destroy the like' do
            post_like
            expect { subject }.to change { user.likes.count }.by(-1)
          end
        end
      end
    end

    context 'for comments' do
      subject { delete :destroy, params: { id: comment_like.id, post_id: example_post.id, user_id: user.id, comment_id: example_comment.id } }

      context 'when no code provided' do
        it_behaves_like 'forbidden_requests'
      end

      context 'when invalid code provided' do
        before { request.headers['authorization'] = 'Invalid token' }
        it_behaves_like 'forbidden_requests'
      end

      context 'when trying to remove not own like' do
        let(:other_user) { create :user }
        let(:other_like) { Like.create(user: other_user, likeble: example_comment) }
        subject { delete :destroy, params: { id: other_like.id, post_id: example_post.id, comment_id: example_comment.id } }
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        it_behaves_like 'forbidden_requests'
      end

      context 'when authorized' do
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        context 'when success request sent' do
          it 'should have 204 status code' do
            subject
            expect(response).to have_http_status(:no_content)
          end

          it 'should have proper json body' do
            subject
            expect(response.body).to be_blank
          end

          it 'should destroy the like' do
            comment_like
            expect { subject }.to change { user.likes.count }.by(-1)
          end
        end
      end
    end
  end
end
