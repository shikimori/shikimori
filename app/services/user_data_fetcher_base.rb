class UserDataFetcherBase
  KlassHistories = {
    Anime => [UserHistoryAction::MalAnimeImport, UserHistoryAction::ApAnimeImport],
    Manga => [UserHistoryAction::MalMangaImport, UserHistoryAction::ApMangaImport]
  }

  def fetch
    return [] unless should_fetch?
    return postprocess(load_data) if load_data

    if Rails.env.development?
      postprocess(job.perform)
    else
      Delayed::Job.enqueue_uniq(job)
      nil
    end
  end

  def postprocess(data)
    data
  end

private
  def list_cache_key
    "userlist_#{@klass}_#{@user.id}_#{latest_import[:id]}_#{histories/10}"
  end

  def cache_key
    "#{self.class}_#{list_cache_key}"
  end

  def histories
    @histories ||= @user.history.count
  end

  def rates
    @rates ||= @user.send("#{@klass.name.downcase}_rates").count
  end

  def latest_import
    @latest_import ||= UserHistory
        .where(user_id: @user.id, action: KlassHistories[@klass])
        .order('id desc')
        .first || {}
  end

  def should_fetch?
    @user.present? &&
      (histories >= Recommendations::RatesFetcher::MinimumScores || latest_import.present?) &&
      rates >= Recommendations::RatesFetcher::MinimumScores
  end

  def load_data
    @loaded_data ||= begin
      data = Rails.cache.read cache_key
      if data.nil?
        false
      else
        data
      end
    end
  end
end
