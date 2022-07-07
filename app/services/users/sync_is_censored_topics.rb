class Users::SyncIsCensoredTopics
  method_object :entry

  def call
    if @entry.preferences.censored_topics?
      @entry.preferences.update is_censored_topics: @entry.age && @entry.age >= 18
    end
  end
end
