class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :text, :slug, :preview_text
end
