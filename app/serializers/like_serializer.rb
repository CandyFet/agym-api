class LikeSerializer < ActiveModel::Serializer
  attributes :id, :user
  
  def user
    object.user
  end
end
