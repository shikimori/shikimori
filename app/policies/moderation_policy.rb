class ModerationPolicy
  prepend ActiveCacher.instance

  pattr_initialize :user, :locale, :moderation_filter

  instance_cache :critiques_count, :collections_count,
    :abuse_requests_total_count,
    :abuse_requests_bannable_count,
    :abuse_requests_not_bannable_count,
    :all_content_versions_count,
    :names_versions_count, :texts_versions_count, :content_versions_count, :fansub_versions_count

  def critiques_count
    return 0 unless !@moderation_filter || @user&.critique_moderator?

    Critique.pending.where(locale: @locale).size
  end

  def collections_count
    return 0 unless !@moderation_filter || @user&.collection_moderator?

    Collection.pending.published.where(locale: @locale).size
  end

  def news_count
    return 0 unless !@moderation_filter || @user&.news_moderator?

    Topics::NewsTopic.pending.where(locale: @locale).size
  end

  def articles_count
    return 0 unless !@moderation_filter || @user&.article_moderator?

    Article.pending.where(locale: @locale).size
  end

  def abuse_requests_total_count
    abuse_requests_bannable_count + abuse_requests_not_bannable_count
  end

  def abuse_requests_bannable_count
    return 0 unless !@moderation_filter || @user&.forum_moderator?

    AbuseRequest.pending.bannable.size
  end

  def abuse_requests_not_bannable_count
    return 0 unless !@moderation_filter || @user&.forum_moderator?

    AbuseRequest.pending.not_bannable.size
  end

  def all_content_versions_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    Moderation::VersionsItemTypeQuery.fetch(:all_content).pending.size
  end

  def names_versions_count
    return 0 unless !@moderation_filter || @user&.version_names_moderator?

    Moderation::VersionsItemTypeQuery.fetch(:names).pending.size
  end

  def texts_versions_count
    return 0 unless !@moderation_filter || @user&.version_texts_moderator?

    Moderation::VersionsItemTypeQuery.fetch(:texts).pending.size
  end

  def content_versions_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    Moderation::VersionsItemTypeQuery.fetch(:content).pending.size
  end

  def fansub_versions_count
    return 0 unless !@moderation_filter || @user&.version_fansub_moderator?

    Moderation::VersionsItemTypeQuery.fetch(:fansub).pending.size
  end
end
