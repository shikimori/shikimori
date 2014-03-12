class AnimeVideosService
  def self.upload_report user, video
    report = AnimeVideoReport.create! user: user, anime_video: video, kind: :uploaded
    report.accept!(user) if user.trusted_video_uploader?
    report
  end
end
