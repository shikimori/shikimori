module Contests
  class ResultsView < ViewObjectBase
    pattr_initialize :contest

    instance_cache :results

    def results
      ApplyRatedEntries.new(h.current_user).call(contest.results)
    end
  end
end
