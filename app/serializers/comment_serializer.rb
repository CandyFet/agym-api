class CommentSerializer < ActiveModel::Serializer
  attributes :header, :body, :actions

  def header
    data_hash = {
      user_name: object.user.name,
      user_avatar_url: object.user.avatar_url,
    }
  end

  def body
    data_hash = {
      text: object.text,
    }
  end

  def actions
    data_hash = {
      likes_total: object.likes.count
    }
  end
end
