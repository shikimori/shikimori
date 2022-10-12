class Comments::UserQuery < QueryObjectBase
  CLUBS_JOIN_SQL = <<~SQL.squish
    left join topics on
      commentable_type='Topic' and commentable_id=topics.id
    left join clubs on
      topics.linked_type='Club' and topics.linked_id=clubs.id
  SQL
  GUEST_CLUBS_WHERE_SQL = <<~SQL.squish
    clubs.id is null or (clubs.is_shadowbanned = false and clubs.is_private = false)
  SQL
  USER_CLUBS_WHERE_SQL = <<~SQL.squish
    #{GUEST_CLUBS_WHERE_SQL} or clubs.id in (?)
  SQL

  def self.fetch user
    scope = Comment
      .includes(:commentable)
      .where(user_id: user.id)
      .order(id: :desc)

    new(scope)
  end

  def restrictions_scope decorated_user
    return self if decorated_user&.moderation_staff?

    scope = @scope.joins(CLUBS_JOIN_SQL)

    chain(
      decorated_user ?
        scope.where(USER_CLUBS_WHERE_SQL, decorated_user.club_ids) :
        scope.where(GUEST_CLUBS_WHERE_SQL)
    )
  end

  def search phrase
    return self if phrase.blank?

    chain @scope.where("comments.body ilike #{ApplicationRecord.sanitize "%#{phrase}%"}")
  end

  def filter_by_policy user
    lazy_filter do |comment|
      Comment::AccessPolicy.allowed? comment, user
    end
  end
end
