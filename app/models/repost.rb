class Repost < ApplicationRecord
  belongs_to :repostable, polymorphic: true
  belongs_to :user

  validates_presence_of :user, :repostable
  validates :user_id, uniqueness: { scope: %i[repostable_id repostable_type] }
end
