require 'rails_helper'

RSpec.describe Post, type: :model do
  describe '#validations' do
    it 'should test that factory is valid' do
      expect(build :post).to be_valid
    end

    it 'should validate the presence of the title' do
      post = build :post, title: ''
      expect(post).not_to be_valid
      expect(post.errors.messages[:title]).to include("can't be blank")
    end

    it 'should validate the presence of the content' do
      post = build :post, text: ''
      expect(post).not_to be_valid
      expect(post.errors.messages[:text]).to include("can't be blank")
    end
  end

  describe '.recent' do
    it 'should list recent post first' do
      old_post = create :post
      newer_post = create :post
      expect(described_class.recent).to eq([newer_post, old_post])
      old_post.update_column :created_at, Time.zone.now
      expect(described_class.recent).to eq([old_post, newer_post])
    end
  end

  describe '.create_slug' do
    it 'should create correct slug' do
      article = create :article, title: 'some title'
      expect(article.create_slug).to eq('some-title')
    end
  end

  describe '.create_preview_text' do
    it 'should create correct preview text' do
      article = create :article, 
        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque tempor diam ut malesuada nisi.'
      expect(article.create_preview_text).to eq('Lorem ipsum dolor sit amet, consectetur adipiscing ')
    end
  end
end
