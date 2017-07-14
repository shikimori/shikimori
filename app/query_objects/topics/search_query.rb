class Topics::SearchQuery
  method_object %i[scope phrase forum user locale]

  SEARCH_LIMIT = 999

  def call
    return @scope if @phrase.blank?

    Search::Topic.call(
      scope: @scope,
      phrase: @phrase,
      forum_id: forum_id,
      locale: @locale,
      ids_limit: SEARCH_LIMIT
    )
  end

private

  def forum_id
    if @forum
      pick_forum_id

    elsif user
      @user.preferences.forums.map(&:to_i) + [Forum::CLUBS_ID]

    else
      Forum.cached.map(&:id)
    end
  end

  def pick_forum_id
    if @forum == Forum::NEWS_FORUM
      Forum.cached.map(&:id)

    elsif @forum == Forum::MY_CLUBS_FORUM
      [Forum::CLUBS_ID]
    else
      @forum.id
    end
  end
end
