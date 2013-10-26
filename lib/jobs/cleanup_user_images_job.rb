class CleanupUserImagesJob
  def perform
    UserImage.where(linked_id: nil)
        .where { created_at.lte(1.week.ago) }
        .destroy_all
  end
end
