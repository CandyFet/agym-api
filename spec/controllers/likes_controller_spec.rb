# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LikesController, type: :controller do
  let(:example_post) { create :post }
  let(:user) { create :user }
  let(:example_post_comment) { example_post.comments.create(text: 'test text', user: user) }
  let(:comment_post_like) { Like.create(user: user, likeble: example_post_comment) }
  let(:post_like) { Like.create(user: user, likeble: example_post) }
  let(:access_token) { user.create_access_token }
  let(:example_article) {create :article }
  let(:example_article_comment) { example_article.comments.create(text: 'test text', user: user) }
  let(:comment_article_like) { Like.create(user: user, likeble: example_article_comment) }
  let(:article_like) { Like.create(user: user, likeble: example_article) }

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
    context 'for post comments' do
      subject { get :index, params: { post_id: example_post.id, comment_id: example_post_comment.id } }
      it 'should return success response' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'should return proper json' do
        comment_post_like
        subject
        expect(json_data.first['attributes']).not_to be_blank
      end
    end

    context 'for articles' do
      subject { get :index, params: { article_id: example_article.id } }
      it 'should return success response' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'should return proper json' do
        article_like
        subject
        expect(json_data.first['attributes']).not_to be_blank
      end
    end

    context 'for article comments' do
      subject { get :index, params: { article_id: example_article.id, comment_id: example_article_comment.id } }
      it 'should return success response' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'should return proper json' do
        comment_article_like
        subject
        expect(json_data.first['attributes']).not_to be_blank
      end
    end
  end

  describe 'POST /create' do
    context 'for posts' do
      subject do
        post :create, params: { post_id: example_post.id }
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


      end
    end

    context 'for post comments' do
      subject do
        post :create, params: { post_id: example_post.id, comment_id: example_post_comment.id, like: {
          likeble_id: example_post_comment.id,
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

      end
    end

    context 'for article' do
      subject do
        post :create, params: { article_id: example_article.id }
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

      end
    end

    context 'for article comments' do
      subject do
        post :create, params: { article_id: example_article.id, comment_id: example_article_comment.id }
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

    context 'for post comments' do
      subject { delete :destroy, params: { id: comment_post_like.id, post_id: example_post.id, user_id: user.id, comment_id: example_post_comment.id } }

      context 'when no code provided' do
        it_behaves_like 'forbidden_requests'
      end

      context 'when invalid code provided' do
        before { request.headers['authorization'] = 'Invalid token' }
        it_behaves_like 'forbidden_requests'
      end

      context 'when trying to remove not own like' do
        let(:other_user) { create :user }
        let(:other_like) { Like.create(user: other_user, likeble: example_post_comment) }
        subject { delete :destroy, params: { id: other_like.id, post_id: example_post.id, comment_id: example_post_comment.id } }
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
            comment_post_like
            expect { subject }.to change { user.likes.count }.by(-1)
          end
        end
      end
    end

    context 'for articles' do
      subject { delete :destroy, params: { id: article_like.id, article_id: example_article.id, user_id: user.id } }

      context 'when no code provided' do
        it_behaves_like 'forbidden_requests'
      end

      context 'when invalid code provided' do
        before { request.headers['authorization'] = 'Invalid token' }
        it_behaves_like 'forbidden_requests'
      end

      context 'when trying to remove not own like' do
        let(:other_user) { create :user }
        let(:other_like) { Like.create(user: other_user, likeble: example_article) }
        subject { delete :destroy, params: { id: other_like.id, article_id: example_article.id } }
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
            article_like
            expect { subject }.to change { user.likes.count }.by(-1)
          end
        end
      end
    end

    context 'for article comments' do
      subject { delete :destroy, params: { id: comment_article_like.id, article_id: example_article.id, user_id: user.id, comment_id: example_article_comment.id } }

      context 'when no code provided' do
        it_behaves_like 'forbidden_requests'
      end

      context 'when invalid code provided' do
        before { request.headers['authorization'] = 'Invalid token' }
        it_behaves_like 'forbidden_requests'
      end

      context 'when trying to remove not own like' do
        let(:other_user) { create :user }
        let(:other_like) { Like.create(user: other_user, likeble: example_article_comment) }
        subject { delete :destroy, params: { id: other_like.id, article_id: example_article.id, comment_id: example_article_comment.id } }
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
            comment_article_like
            expect { subject }.to change { user.likes.count }.by(-1)
          end
        end
      end
    end
  end
end
