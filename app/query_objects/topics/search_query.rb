class Topics::SearchQuery
  method_object %i[scope phrase forum user]

  SEARCH_LIMIT = 999

  def call
    return @scope if @phrase.blank?

    Search::Topic.call(
      scope: @scope,
      phrase: @phrase,
      forum_id: forum_id,
      ids_limit: SEARCH_LIMIT
    )
  end

private

  def forum_id
    if @forum
      pick_forum_id

    elsif @user
      @user.preferences.forums.map(&:to_i) + [Forum::CLUBS_ID]

    else
      Forum.cached.map(&:id)
    end
  end

  def pick_forum_id
    if @forum.id  == Forum::NEWS_ID
      Forum.cached.map(&:id)

    elsif @forum == Forum::MY_CLUBS_FORUM
      [Forum::CLUBS_ID]

    elsif @forum == Forum::UPDATES_FORUM
      [Forum::ANIME_NEWS_ID]

    else
      @forum.id
    end
  end
end
