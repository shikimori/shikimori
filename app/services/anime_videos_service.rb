class AnimeVideosService
  pattr_initialize :params, :user

  def create
    if created_video.persisted? && created_video.uploaded?
      created_video.reports.create! user_id: user.try(:id) || User::GuestID, kind: :uploaded
    end

    created_video
  end

private
  def created_video
    @video ||= AnimeVideo.create params.except(:url, :author) do |video|
      video.url = fetch_url params[:url]
      video.author = fetch_author params[:author]
    end
  end

  def fetch_url video_url
    VideoExtractor::UrlExtractor.new(video_url).extract
  end

  def fetch_author author_name
    AnimeVideoAuthor.find_or_create_by name: author_name.to_s.strip
  end
end
