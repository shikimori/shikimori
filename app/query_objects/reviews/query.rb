class Reviews::Query < QueryObjectBase
  NEW_REVIEW_BUBBLE_INTERVAL = 2.days

  def self.fetch db_entry
    new db_entry
      .reviews
      .includes(
        :user,
        db_entry.anime? ? :anime : :manga,
        :topic
      )
      .order(id: :desc)
  end

  def by_opinion opinion
    return self if opinion.blank?

    chain @scope.where(opinion: Types::Review::Opinion[opinion])

    # [
    #   bubbled(scope),
    #   not_bubbled(scope)
    # ].compact.flatten.uniq
  end

private

  # def bubbled reviews
  #   reviews
  #     .select { |v| v.created_at + NEW_REVIEW_BUBBLE_INTERVAL > Time.zone.now }
  #     .sort_by { |v| - v.id }
  # end
  #
  # def not_bubbled reviews
  #   reviews
  #     .select { |v| v.created_at + NEW_REVIEW_BUBBLE_INTERVAL <= Time.zone.now }
  #     .sort_by { |v| -(v.cached_votes_up - v.cached_votes_down) }
  # end
end
