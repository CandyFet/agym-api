class AccessToken < ApplicationRecord
  after_initialize :generate_token
  belongs_to :user
  validates :token, presence: true, uniqueness: true

  private

  def generate_token
    loop do
      break if token.present? && !AccessToken.where.not(id: id).exists?(token: token)
      self.token = SecureRandom.hex(10)
    end
  end
end
