require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '#valdiations' do
    it 'should have a valid factory' do
      expect(build :comment).to be_valid
    end

    it 'should validate presence of attributes' do
      comment = Comment.new
      expect(comment).not_to be_valid
      expect(comment.errors.messages).to include(
        {
          user: ['must exist'],
          commentable: ['must exist'],
          text: ["can't be blank"]
        }
      )
    end
  end
end
