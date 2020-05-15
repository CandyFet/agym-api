class PostSerializer < ActiveModel::Serializer
  attributes :header, :body, :actions

  def header
    data_hash = {
      title: object.title,
      user_name: object.user.name,
      user_avatar_url: object.user.avatar_url,
      slug: object.slug,
    }
  end

  def body
    data_hash = {
      text: object.text,
      preview_text: object.preview_text
    }
  end

  def actions
    data_hash = {
      likes_total: object.likes.count,
      reposts_total: object.reposts.count,
      comments_total: object.comments.count
    }
  end
end
