require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe '#validations' do
    it 'should have valid factory' do
      access_token = build :user
      expect(access_token).to be_valid
    end

    it 'should validate token' do
      access_token = build :access_token, token: nil
      expect(access_token).not_to be_valid
      expect(access_token.errors.messages[:token]).to include("can't be blank")
    end

    it 'should validate uniqueness of token' do
      user = create :user
      other_user = create :user
      access_token = create :access_token, user_id: user.id
      other_access_token = build :access_token, token: access_token.token, user_id: other_user.id
      expect(other_access_token).not_to be_valid
      other_access_token.token = 'newtoken'
      expect(other_access_token).to be_valid
    end
  end

  describe '#new' do
    it 'should be present after initialization' do
      expect(AccessToken.new).to be_present
    end

    it 'should generate uniq token' do
      user = create :user
      expect{ user.create_access_token }.to change{ AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end

    it 'should generate token once' do
      user = create :user
      access_token = user.create_access_token
      expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end
