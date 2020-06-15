# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :header, :body, :actions

  def header
    data_hash = {
      name: object.name,
      avatar_url: object.avatar_url,
      login: object.login,
      admin: object.admin?,
      ambassador: object.ambassador?,
      trainer: object.trainer?
    }
    end

  def body
    data_hash = {

    }
  end

  def actions
    data_hash = {

    }
  end
end
