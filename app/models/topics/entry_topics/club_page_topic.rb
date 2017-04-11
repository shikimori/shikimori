class Topics::EntryTopics::ClubPageTopic < Topics::EntryTopic
  include Topics::EntryTopics::ClubTopicPermissions

  def title
    linked.name
  end

  def club
    linked.club
  end

  def i18n_params
    { club_page_id: linked_id, club_id: linked.club_id }
  end
end
