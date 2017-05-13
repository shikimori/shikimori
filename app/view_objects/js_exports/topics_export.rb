class JsExports::TopicsExport < JsExports::ExportBase
  VOTEABLE_TYPES = [
    Review.name,
    CosplayGallery.name,
    Collection.name
  ]

private

  def fetch_entries user
    Topic
      .with_viewed(user)
      .where(id: tracked_ids)
      .select("topics.id, topics.created_at, #{Topic::VIEWED_JOINS_SELECT}")
      .order(:id)
  end

  def serialize topic, user
    ability = Ability.new user
    {
      can_destroy: ability.can?(:destroy, topic),
      can_edit: ability.can?(:edit, topic),
      id: topic.id,
      is_viewed: topic.viewed?,
      user_id: topic.user_id
    }.merge(vote_status(topic, user))
  end

  def vote_status topic, user
    if VOTEABLE_TYPES.include? topic.linked_type
      {
        voted_yes: topic.linked.voted_yes?(user),
        voted_no: topic.linked.voted_no?(user)
      }
    else
      {}
    end
  end
end
