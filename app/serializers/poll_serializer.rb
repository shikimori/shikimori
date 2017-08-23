class PollSerializer < ActiveModel::Serializer
  attributes :id, :name, :text, :text_html, :state, :votes_total
  has_many :variants

  def votes_total
    object.variants.sum(&:cached_votes_total)
  end
end
