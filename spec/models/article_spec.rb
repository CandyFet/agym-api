require 'rails_helper'

RSpec.describe Article, type: :model do
  describe '#validations' do
    it 'should test that factory is valid' do
      expect(build :article).to be_valid
    end

    it 'should validate the presence of the title' do
      article = build :article, title: ''
      expect(article).not_to be_valid
      expect(article.errors.messages[:title]).to include("can't be blank")
    end

    it 'should validate the presence of the content' do
      article = build :article, text: ''
      expect(article).not_to be_valid
      expect(article.errors.messages[:text]).to include("can't be blank")
    end
  end

  describe '.recent' do
    it 'should list recent article first' do
      old_article = create :article
      newer_article = create :article
      expect(described_class.recent).to eq([newer_article, old_article])
      old_article.update_column :created_at, Time.zone.now
      expect(described_class.recent).to eq([old_article, newer_article])
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
