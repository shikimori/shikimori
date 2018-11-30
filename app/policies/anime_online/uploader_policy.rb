class AnimeOnline::UploaderPolicy
  pattr_initialize :user

  def trusted?
    return false if user.not_trusted_video_uploader?

    user.trusted_video_uploader? || responsible_uploaders.include?(user.id)
  end

private

  def responsible_uploaders
    @responsible_uploaders ||= AnimeOnline::ResponsibleUploaders.call
  end
end
