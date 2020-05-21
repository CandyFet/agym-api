# frozen_string_literal: true

class Article < ApplicationRecord
  validates :title, presence: true
  validates :text, presence: true

  after_save lambda {
    create_slug
    create_preview_text
  }

  belongs_to :user

  include Commentable
  include Likeble
  include Repostable

  scope :recent, -> { order(created_at: :desc) }

  paginates_per 10

  def create_slug
    self.slug ||= title.parameterize if title.present?
  end

  def create_preview_text
    self.preview_text = text[0..50] if text.present?
  end
end
