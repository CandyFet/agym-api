# frozen_string_literal: true

module Repostable
  extend ActiveSupport::Concern

  included do
    has_many :reposts, as: :repostable, dependent: :destroy
  end
end
