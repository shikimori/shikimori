class Collections::SyncTopicsIsCensored
  method_object :entry

  def call
    @entry.all_topics.update_all is_censored: @entry.censored?
  end
end
