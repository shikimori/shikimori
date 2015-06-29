class AnimeVideosService
  pattr_initialize :params

  def create user
    if created_video.persisted? && created_video.uploaded?
      created_video.reports.create! user_id: user.try(:id) || User::GuestID, kind: :uploaded
    end

    created_video
  end

  def update video, current_user
    return if video.author_name == params[:author_name] && video.episode == params[:episode] && video[:kind] == params[:kind]

    video.moderated_update params, current_user
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
end
