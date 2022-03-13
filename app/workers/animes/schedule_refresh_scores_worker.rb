class Animes::ScheduleRefreshScoresWorker
  include Sidekiq::Worker

  sidekiq_options queue: :cpu_intensive

  Type = Types::Coercible::String.enum(Anime.name, Manga.name)

  def perform kind
    @entry_class = Kind[kind].classify.constantize
    ids_to_update.each do |entry_id|
      Animes::RefreshScoresWorker.perform_async(@entry_class.name, entry_id, global_average)
    end
  end

  private

  def ids_to_update
    if @entry_class.where('score_2 > 0').any?
      recently_updated_ids
    else
      all_ids
    end
  end

  def recently_updated_ids
    UserRate
      .where('updated_at > ?', 1.day.ago)
      .where(target_type: @entry_class.to_s)
      .select(:target_id)
      .distinct(:target_id)
      .pluck(:target_id)
  end

  def all_ids
    UserRate
      .where(target_type: @entry_class.to_s)
      .select(:target_id)
      .distinct(:target_id)
      .pluck(:target_id)
  end

  def global_average
    UserRate
      .where(target_type: @entry_class.to_s)
      .where('score > 0')
      .average(:score)
  end
end
