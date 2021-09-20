class Critiques::Query
  NEW_REVIEW_BUBBLE_INTERVAL = 2.days
  method_object :db_entry, %i[locale! id]

  def call
    scope = @db_entry.critiques
      .includes(:user, :topics)
      .where(locale: @locale)

    if @id.present? && @id != 0
      scope.where(id: @id)
    else
      scope = scope.visible

      [
        bubbled(scope),
        not_bubbled(scope)
      ].compact.flatten.uniq
    end
  end

private

  def bubbled critiques
    critiques
      .select { |v| v.created_at + NEW_REVIEW_BUBBLE_INTERVAL > Time.zone.now }
      .sort_by { |v| - v.id }
  end

  def not_bubbled critiques
    critiques
      .select { |v| v.created_at + NEW_REVIEW_BUBBLE_INTERVAL <= Time.zone.now }
      .sort_by { |v| -(v.cached_votes_up - v.cached_votes_down) }
  end
end
