class Post < ApplicationRecord
  validates :title, presence: true
  validates :text, presence: true

  after_save -> do
    self.create_slug
    self.create_preview_text
  end

  belongs_to :user
  
  include Commentable
  include Likeble
  include Repostable

  scope :recent, -> { order(created_at: :desc) }

  paginates_per 10

  def create_slug
    self.slug ||= self.title.parameterize if self.title.present?
  end

  def create_preview_text
    self.preview_text = self.text[0..50] if self.text.present?
  end
end
