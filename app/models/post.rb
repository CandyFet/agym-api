class Post < ApplicationRecord
  validates :title, presence: true
  validates :text, presence: true


  after_initialize -> do
    self.create_slug
    self.create_preview_text
  end

  belongs_to :user
  
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likeble, dependent: :destroy
  has_many :reposts, as: :repostable, dependent: :destroy

  scope :recent, -> { order(created_at: :desc) }

  def create_slug
    self.slug ||= self.title.parameterize if self.title.present?
  end

  def create_preview_text
    self.preview_text = self.text[0..50] if self.text.present?
  end
end
