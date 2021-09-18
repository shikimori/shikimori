class Critiques::Query
  NEW_REVIEW_BUBBLE_INTERVAL = 2.days

  def initialize entry, user, locale, id = 0
    @entry = entry
    @user = user
    @locale = locale
    @id = id
  end

  def fetch
    critiques = @entry.critiques
      .includes(:user, :topics)
      .where(locale: @locale)

    if @id.present? && @id != 0
      critiques.where(id: @id)
    else
      critiques = critiques.visible
      [
        bubbled(critiques),
        not_bubbled(critiques)
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
