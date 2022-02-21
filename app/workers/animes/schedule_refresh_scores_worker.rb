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

    ids = UserRate.where('updated_at > ?', 100.days.ago).where(
      target_type: entry_class.to_s
    ).select(:target_id).distinct(:target_id).pluck(:target_id)

    ids.each do |entry_id|
      RefreshScoresWorker.perform_async(entry_class, entry_id, global_average)
    end
  end

  def global_average
    UserRate.where(
      target_type: entry_class.to_s
    ).where('score > 0').average(:score) / 10
  end
end
