require 'rails_helper'

RSpec.describe Repost, type: :model do
  describe '#valdiations' do
    it 'should have a valid factory' do
      expect(build :repost).to be_valid
    end

    it 'should validate presence of attributes' do
      repost = Repost.new
      expect(repost).not_to be_valid
      expect(repost.errors.messages).to include(
        {
          user: ['must exist', "can't be blank"],
          repostable: ['must exist', "can't be blank"]
        }
      )
    end

    it 'should validate uniqueness of user for likeble' do
      user = create :user
      post = create :post
      first_repost = create :repost, user: user, repostable: post
      second_repost = build :repost, user: user, repostable: post
      expect(first_repost).to be_valid
      expect(second_repost).not_to be_valid
    end
  end
end
