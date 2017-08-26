class PollVariantSerializer < ActiveModel::Serializer
  attributes :id, :label, :votes_total, :vote_for_url

  def votes_total
    object.cached_votes_total
  end

  def vote_for_url
    UrlGenerator.instance.votes_url vote: {
      votable_id: object.id,
      votable_type: object.class.name,
      vote: 'yes'
    }
  end
end
