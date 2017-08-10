class PollSerializer < ActiveModel::Serializer
  attributes :id
  has_many :poll_variants
end
