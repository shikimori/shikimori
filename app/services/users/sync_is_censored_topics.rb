class Users::SyncIsCensoredTopics
  method_object :entry

  def call
    if @entry.preferences.view_censored?
      @entry.preferences.update is_view_censored: @entry.age && @entry.age >= 18
    end
  end
end
