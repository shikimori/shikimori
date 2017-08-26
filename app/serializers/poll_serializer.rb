class PollSerializer < ActiveModel::Serializer
  attributes :id, :name, :text, :text_html, :state, :votes_total,
    :vote_abstain_url, :vote
  has_many :variants

  def votes_total
    object.variants.sum(&:cached_votes_total)
  end

  def vote_abstain_url
    UrlGenerator.instance.votes_url vote: {
      votable_id: object.id,
      votable_type: object.class.name,
      vote: 'yes'
    }
  end

  def vote
    is_abstained = scope&.liked?(object)
    {
      is_abstained: is_abstained,
      variant_id: (
        object.variants.find { |v| scope&.liked? v }&.id unless is_abstained
      )
    }
  end
end
