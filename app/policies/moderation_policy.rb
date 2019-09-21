class ModerationPolicy
  prepend ActiveCacher.instance

  pattr_initialize :user, :locale, :moderation_filter

  instance_cache :reviews_count, :collections_count, :abuse_count,
    :texts_versions_count, :content_versions_count, :fansub_versions_count

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
    return 0 unless !@moderation_filter || @user&.version_texts_moderator?

    Moderation::VersionsItemTypeQuery.call(:texts).pending.size
  end

  def content_versions_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    Moderation::VersionsItemTypeQuery.call(:content).pending.size
  end

  def fansub_versions_count
    return 0 unless !@moderation_filter || @user&.version_fansub_moderator?

    Moderation::VersionsItemTypeQuery.call(:fansub).pending.size
  end
end
