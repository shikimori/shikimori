class PollSerializer < ActiveModel::Serializer
  attributes :id, :name, :state, :votes_total
  has_many :variants

  def votes_total
    object.variants.sum(&:cached_votes_total)
  end
end
