class SimilarUsersFetcher < UserDataFetcherBase
  def initialize(user, klass, threshold)
    @user = user
    @klass = klass
    @threshold = threshold
  end

private
  def job
    SimilarUsersJob.new @user.id, @klass.name, @threshold, cache_key
  end

  def cache_key
    "#{super}_#{@threshold}_#{SimilarUsersService::ResultsLimit}"
  end
end
