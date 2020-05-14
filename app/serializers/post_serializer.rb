class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :text, :slug, :preview_text, :likes_count
  has_one :user

  def likes_count
    object.likes.count
  end
end
