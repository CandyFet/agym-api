class Post < ApplicationRecord
  validates :title, presence: true
  validates :text, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :preview_text, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
