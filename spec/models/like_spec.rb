require 'rails_helper'

RSpec.describe Like, type: :model do
  describe '#valdiations' do
    it 'should have a valid factory' do
      expect(build :like).to be_valid
      expect(build :like, :for_comment).to be_valid
    end

    it 'should validate presence of attributes' do
      like = Like.new
      expect(like).not_to be_valid
      expect(like.errors.messages).to include(
        {
          user: ['must exist', "can't be blank"],
          likeble: ['must exist', "can't be blank"]
        }
      )
    end

    it 'should validate uniqueness of user for likeble' do
      user = create :user
      comment = create :comment
      post = create :post
      first_like = create :like, user: user, likeble: comment
      second_like = build :like, user: user, likeble: comment
      expect(first_like).to be_valid
      expect(second_like).not_to be_valid
      third_like = create :like, user: user, likeble: post
      fourth_like = build :like, user: user, likeble: post
      expect(first_like).to be_valid
      expect(second_like).not_to be_valid
    end
  end
end
