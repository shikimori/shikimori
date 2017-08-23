class PollVariantSerializer < ActiveModel::Serializer
  attributes :text, :votes_total, :votes_percent

  def votes_total
    object.cached_votes_total
  end

  def votes_percent
    object.votes_percent
  end
end
