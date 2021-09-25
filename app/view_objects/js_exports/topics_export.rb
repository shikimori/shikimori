class JsExports::TopicsExport < JsExports::ExportBase
  VOTABLE_TYPES = [
    Critique.name,
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
      **vote_status(topic, user),
      can_destroy: can_destroy?(ability, topic),
      can_edit: can_edit?(ability, topic),
      id: topic.id,
      is_viewed: topic.viewed?,
      user_id: topic.user_id
    }
  end

  def vote_status topic, user
    return {} unless votable? topic

    {
      voted_yes: user.liked?(topic.linked),
      voted_no: user.disliked?(topic.linked),
      votes_for: topic.linked.cached_votes_up,
      votes_against: topic.linked.cached_votes_down
    }
  end

  def can_edit? ability, topic
    if votable? topic
      ability.can? :edit, topic.linked
    else
      ability.can? :edit, topic
    end
  end

  def can_destroy? ability, topic
    if votable? topic
      ability.can? :destroy, topic.linked
    else
      ability.can? :destroy, topic
    end
  end

  def votable? topic
    VOTABLE_TYPES.include? topic.linked_type
  end
end
