class ModerationPolicy
  prepend ActiveCacher.instance

  pattr_initialize :user, :locale, :moderation_filter

  instance_cache :reviews_count, :abuse_abuses_count,
    :abuse_pending_count, :other_versions_count, :video_versions_count

  def reviews_count
    return 0 unless !@moderation_filter || @user&.review_moderator?

    Review.pending.where(locale: @locale).size
  end

  def collections_count
    return 0 unless !@moderation_filter || @user&.collection_moderator?

    Collection.pending.published.where(locale: @locale).size
  end

  def abuses_count
    return 0 unless !@moderation_filter || @user&.forum_moderator?

    AbuseRequest.abuses.size + AbuseRequest.pending.size
  end

  def texts_versions_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    Version.pending_texts.size
  end

  def content_versions_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    Version.pending_content.size
  end

  def fansub_versions_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    Version.pending_fansub.size
  end

  def videos_count
    return 0 unless !@moderation_filter || @user&.video_moderator?

    Version.pending_videos.size
  end
end
