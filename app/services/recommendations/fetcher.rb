# Выборка рекомендаций
# fetch возвращает:
#   пустой массив - не удалось подобрать ничего
#   nil - запущен подбор, пока ничего не готово
#   массив id - массив с id рекомендованных элементов
class Recommendations::Fetcher < UserDataFetcherBase
  method_object %i[user! klass! metric! threshold!]

private

  def job
    RecommendationsWorker
  end

  def job_args
    [
      @user.id,
      @klass.base_class.name,
      @metric,
      @threshold,
      cache_key,
      list_cache_key
    ]
  end

  def cache_key
    "#{super}_#{@metric}_#{@threshold}"
  end

  # удаление из рекомендаций заблокированных пользователем аниме
  def postprocess data
    exclude_ids = Recommendations::ExcludedIds.call @user, @klass
    data&.delete_if { |id, _rating| exclude_ids.include? id }
  end
end
