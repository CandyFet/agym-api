# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepostsController, type: :controller do
  let(:user) { create :user }
  let(:access_token) { user.create_access_token }
  let(:example_post) { create :post }
  let(:repost) { create :repost, repostable: example_post, user: user }
  describe '#create' do
    context 'for posts' do
      subject do
        post :create, params: { post_id: example_post.id, repost: {
          repostable_id: example_post.id,
          repostable_type: 'Post'
        } }
      end

      context 'when not authorized' do
        it_behaves_like 'forbidden_requests'
      end

      context 'when authorized' do
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        context 'with valid parameters' do
          it 'should create new repost' do
            expect { subject }.to change(Repost, :count).by(1)
          end

          it 'should render proper json for new repost' do
            subject
            expect(response).to have_http_status(:created)
            expect(response.content_type).to match(a_string_including('application/json'))
          end
        end

        context 'with invalid parameters' do
          subject do
            post :create, params: { post_id: example_post.id, repost: {
              repostable_id: nil,
              repostable_type: nil
            } }
          end
          it 'should not create a new repost' do
            expect { subject }.to change(Repost, :count).by(0)
          end

          it 'should render a JSON response with errors for the new repost' do
            subject

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
        end
      end
    end
  end

  describe '#destroy' do
    subject { delete :destroy, params: { post_id: example_post.id, id: repost.id, user_id: user.id } }

    context 'when not authorized' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
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

        it 'should destroy the repost' do
          repost
          expect { subject }.to change { user.reposts.count }.by(-1)
        end
      end
    end
  end
end
