class PollSerializer < ActiveModel::Serializer
  attributes :id, :name, :text, :text_html, :width, :state, :vote_abstain_url, :vote
  has_many :variants

  def vote_abstain_url
    UrlGenerator.instance.votes_url(
      votable_id: object.id,
      votable_type: object.class.name,
      vote: 'yes'
    )
  end

  def vote
    is_abstained = !!scope&.liked?(object)
    {
      is_abstained: is_abstained,
      variant_id: (
        object.variants.find { |v| scope&.liked? v }&.id unless is_abstained
      )
    }
  end
end
