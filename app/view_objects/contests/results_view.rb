class Contests::ResultsView < ViewObjectBase
  pattr_initialize :contest

  instance_cache :results

  def results
    contest.results
  end
end
