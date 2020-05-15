class Like < ApplicationRecord
    belongs_to :user
    belongs_to :likeble, polymorphic: true

    validates_presence_of :user, :likeble
    validates :user_id, uniqueness: { scope: %i[likeble_id likeble_type] }
end
