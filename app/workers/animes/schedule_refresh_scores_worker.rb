class Animes::ScheduleRefreshScoresWorker
  include Sidekiq::Worker
  Type = Types::Coercible::String.enum(Anime.name, Manga.name)

  def perform type
    klass = Type[type].constantize
    global_average = Animes::GlobalAverage.call Type[type]

    ids_to_update(klass).each do |entry_id|
      Animes::RefreshScoresWorker.perform_async type, entry_id, global_average
    end
  end

  private

  def ids_to_update klass
    if klass.where('score_2 > 0').any?
      recently_updated_ids klass
    else
      all_ids klass
    end
  end

  def recently_updated_ids klass
    UserRate
      .where('updated_at > ?', 1.day.ago.beginning_of_day)
      .where(target_type: klass.name)
      .select(:target_id)
      .distinct(:target_id)
      .pluck(:target_id)
  end

  def all_ids klass
    UserRate
      .where(target_type: klass.name)
      .select(:target_id)
      .distinct(:target_id)
      .pluck(:target_id)
  end
end
