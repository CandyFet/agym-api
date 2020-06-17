class AccessTokenSerializer < ActiveModel::Serializer
  attributes :id, :token, :user
end
