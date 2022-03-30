class Topics::EntryTopics::ClubTopic < Topics::EntryTopic
  # include PermissionsPolicy

  def club
    linked
  end
end
