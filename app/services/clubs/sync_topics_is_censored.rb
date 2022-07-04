class Clubs::SyncTopicsIsCensored
  method_object :entry

  def call
    @entry.all_topics.update_all is_censored: @entry.censored?
    club_page_topics_scope.update_all is_censored: @entry.censored?
  end

private

  def club_page_topics_scope
    Topic.where(
      linked_type: 'ClubPage',
      linked_id: @entry.pages.select(:id)
    )
  end
end
