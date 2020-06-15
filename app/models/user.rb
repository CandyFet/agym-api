# frozen_string_literal: true

class User < ApplicationRecord
  include BCrypt

  validates :login, presence: true, uniqueness: true
  validates :provider, presence: true
  validates :password, presence: true, if: -> { provider == 'standard' }

  has_one :access_token, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :reposts, dependent: :destroy
  has_many :articles, dependent: :destroy

  paginates_per 10

  def password
    if encrypted_password.present?
      @password ||= Password.new(encrypted_password)
      end
  end

  def password=(new_password)
    return @password = new_password if new_password.blank?
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end
end
