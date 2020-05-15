class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  has_many :likes, as: :likeble, dependent: :destroy

  validates :text, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
