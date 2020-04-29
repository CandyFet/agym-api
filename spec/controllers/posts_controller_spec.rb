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
      expect(json_data['attributes']).to eq({
          'title'=> post.title,
          'text' => post.text,
          'slug' => post.slug,
          'preview-text' => post.preview_text
      })
    end
  end
end