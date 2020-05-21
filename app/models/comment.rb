class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true


  include Likeble

  validates :text, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
