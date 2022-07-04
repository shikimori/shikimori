class Animes::SyncTopicsIsCensored
  method_object :entry

  def call
    @entry.all_topics.update_all is_censored: @entry.censored?
    critique_topics_scope
      .or(review_topics_scope)
      .update_all is_censored: @entry.censored?
  end

private

  def critique_topics_scope
    Topic.where(
      linked_type: 'Critique',
      linked_id: @entry.critiques.select(:id)
    )
  end

  def review_topics_scope
    Topic.where(
      linked_type: 'Review',
      linked_id: @entry.reviews.select(:id)
    )
  end
end
