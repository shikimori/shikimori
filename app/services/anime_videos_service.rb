class AnimeVideosService
  pattr_initialize :params

  def create user
    if created_video.persisted? && created_video.uploaded?
      created_video.reports.create! user_id: user.try(:id) || User::GuestID, kind: :uploaded
    end

    created_video
  end

  def update video
    return if video.author_name == params[:author_name] && video.episode == params[:episode] && video[:kind] == params[:kind]

    video.moderated_update params
    video
  end

private
  def created_video
    @video ||= AnimeVideo.create(video_params) do |video|
      video.url = fetch_url params[:url]
    end
  end

  def video_params
    params.except(:url)
  end

  def fetch_url video_url
    VideoExtractor::UrlExtractor.new(video_url).extract
  end

  def fetch_author author_name
    AnimeVideoAuthor.find_or_create_by name: author_name.to_s.strip
  end
end
