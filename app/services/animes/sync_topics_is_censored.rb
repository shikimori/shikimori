class Animes::SyncTopicsIsCensored
  method_object :entry

  def call
    @entry.all_topics.update_all is_censored: @entry.is_censored
    critiques_scope
      .or(reviews_scope)
      .update_all is_censored: @entry.is_censored
  end

private

  def critiques_scope
    Topic.where(
      linked_type: 'Critique',
      linked_id: @entry.critiques.select(:id)
    )
  end

  def reviews_scope
    Topic.where(
      linked_type: 'Review',
      linked_id: @entry.reviews.select(:id)
    )
  end
end
