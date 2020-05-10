class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :text, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
