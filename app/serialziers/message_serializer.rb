class MessageSerializer < ActiveModel::Serializer
  attributes :id, :kind, :read, :body, :created_at
  has_one :src
end
