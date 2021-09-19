class Users::ActivityStatsQuery
  method_object :user

  def call
    Users::ActivityStats.new(
      Users::ActivityStats.attributes.each_with_object({}) do |field, memo|
        memo[field] = public_send field
      end
    )
  end

  def comments_count
    Comment.where(is_summary: false, user_id: @user.id).count
  end

  def topics_count
    Topic
      .where(user_id: @user.id)
      .user_topics
      .count
  end

  def summaries_count
    Comment.where(is_summary: true, user_id: @user.id).count
  end

  def critiques_count
    @user.critiques.available.count
  end

  def collections_count
    @user.collections.publicly_available.count
  end

  def articles_count
    @user.articles.available.count
  end

  def versions_count
    @user
      .versions
      .where(state: %i[taken accepted auto_accepted])
      .where.not(item_type: AnimeVideo.name)
      .count
  end

  def video_uploads_count
    AnimeVideoReport
      .where(user: @user)
      .where(kind: :uploaded)
      .where.not(state: %i[rejected post_rejected])
      .count
  end

  def video_reports_count
    AnimeVideoReport
      .where(user: @user)
      .where.not(kind: :uploaded)
      .where.not(state: %i[rejected post_rejected])
      .count
  end

  def video_versions_count
    @user
      .versions
      .where(state: %i[taken accepted auto_accepted])
      .where(item_type: AnimeVideo.name)
      .count
  end
end
