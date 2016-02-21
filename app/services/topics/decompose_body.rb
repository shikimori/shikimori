class Topics::DecomposeBody < ServiceObjectBase
  pattr_initialize :topic

  instance_cache :appended_body, :wall_video, :wall_images

  WALL_VIDEO = /\[video = (?<id>\d+) \]/mix
  WALL_IMAGE = /\[(?:poster|image) = (?<id>\d+) \]/mix

  def wall_video
    ids = appended_body.scan(WALL_VIDEO).map { |v| v[0].to_i }
    Video.find_by(id: ids)
  end

  def wall_images
    ids = appended_body.scan(WALL_IMAGE).map { |v| v[0].to_i }
    UserImage.where(id: ids).sort_by { |v| ids.index v.id }
  end

private

  def appended_body
    topic.appended_body
  end
end
