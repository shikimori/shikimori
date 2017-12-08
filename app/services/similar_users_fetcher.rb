class SimilarUsersFetcher < UserDataFetcherBase
  method_object %i[user! klass! threshold!]

private

  def job
    SimilarUsersWorker
  end

  def job_args
    [@user.id, @klass.name, @threshold, cache_key]
  end

  def cache_key
    "#{super}_#{@threshold}_#{SimilarUsersService::MAXIMUM_RESULTS}"
  end
end
