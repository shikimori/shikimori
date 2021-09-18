class ModerationPolicy
  prepend ActiveCacher.instance

  pattr_initialize :user, :locale, :moderation_filter

  instance_cache :critiques_count, :collections_count,
    :abuses_total_count,
    :abuses_abuses_count,
    :abuses_pending_count,
    :all_content_versions_count,
    :names_versions_count, :texts_versions_count, :content_versions_count, :fansub_versions_count

  def reviews_count
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

  def abuses_total_count
    abuses_abuses_count + abuses_pending_count
  end

  def abuses_abuses_count
    return 0 unless !@moderation_filter || @user&.forum_moderator?

    AbuseRequest.abuses.size
  end

  def abuses_pending_count
    return 0 unless !@moderation_filter || @user&.forum_moderator?

    AbuseRequest.pending.size
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
