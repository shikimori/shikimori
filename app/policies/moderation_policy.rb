class ModerationPolicy
  prepend ActiveCacher.instance

  pattr_initialize :user, :locale

  instance_cache :reviews_count, :abuse_abuses_count,
    :abuse_pending_count, :other_versions_count, :video_versions_count

  def reviews_count
    Review.pending.where(locale: @locale).size
  end

  def collections_count
    Collection.pending.published.where(locale: @locale).size
  end

  def abuses_count
    AbuseRequest.abuses.size + AbuseRequest.pending.size
  end

  def content_count
    Version.pending_content.size
  end

  def videos_count
    Version.pending_videos.size
  end

  def video_reports_count
    AnimeVideoReport.pending.size
  end
end
