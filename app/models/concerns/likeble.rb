# frozen_string_literal: true

module Likeble
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likeble, dependent: :destroy
  end
end
