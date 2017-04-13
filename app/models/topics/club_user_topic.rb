class Topics::ClubUserTopic < Topic
  include Topics::EntryTopics::ClubTopicPermissions

  def club
    linked
  end
end
