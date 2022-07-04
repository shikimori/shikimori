class Animes::SyncTopicsIsCensored
  method_object :entry

  def call
    @entry.all_topics.update_all is_censored: @entry.is_censored
  end
end
