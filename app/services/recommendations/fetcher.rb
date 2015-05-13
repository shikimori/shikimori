# Выборка рекомендаций
# fetch возвращает:
#   пустой массив - не удалось подобрать ничего
#   nil - запущен подбор, пока ничего не готово
#   массив id - массив с id рекомендованных элементов
class Recommendations::Fetcher < UserDataFetcherBase
  def initialize user, klass, metric, threshold
    @user = user
    @klass = klass
    @metric = metric
    @threshold = threshold
  end

private
  def job
    RecommendationsWorker
  end

  def job_args
    [@user.id, @klass.name, @metric, @threshold, cache_key, list_cache_key]
  end

  def cache_key
    "#{super}_#{@metric}_#{@threshold}"
  end

  # удаление из рекомендаций заблокированных пользователем аниме
  def postprocess data
    blocked = Set.new RecommendationIgnore.blocked @klass, @user
    if data
      data.delete_if {|id,rating| blocked.include? id }
    else
      data
    end
  end
end
