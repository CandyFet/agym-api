class CommentSerializer < ActiveModel::Serializer
  attributes :id, :text, :likes_count
  has_one :post
  has_one :user

  
  def likes_count
    object.likes.count
  end
end
