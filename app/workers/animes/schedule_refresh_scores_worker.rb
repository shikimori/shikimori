class Animes::ScheduleRefreshScoresWorker
  include Sidekiq::Worker

  def perform(kind)
    case kind
    when 'anime'
      entry_class = Anime
    when 'manga'
      entry_class = Manga
    else
      raise 'wrong class name for scores update'
    end

    ids_to_update.each do |entry_id|
      RefreshScoresWorker.perform_async(entry_class, entry_id, global_average)
    end
  end

  def ids_to_update
    # check for initial database score update
    if entry_class.where('score_2 > 0').any?
      recently_updated_ids
    else
      all_ids
    end
  end

  def recently_updated_ids
    UserRate.where('updated_at > ?', 1.day.ago).where(
      target_type: entry_class.to_s
    ).select(:target_id).distinct(:target_id).pluck(:target_id)
  end

  def all_ids
    UserRate.where(
      target_type: entry_class.to_s
    ).select(:target_id).distinct(:target_id).pluck(:target_id)
  end

  def global_average
    UserRate.where(
      target_type: entry_class.to_s
    ).where('score > 0').average(:score) / 10
  end
end
