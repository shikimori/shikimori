class AnimeOnline::FilterSovetRomantica < ServiceObjectBase
  pattr_initialize :videos

  AUTHOR_NAME = 'SovetRomantica'
  HOSTING_NAME = 'sovetromantica.com'

  def call
    return unless @videos
    @videos.select do |video|
      video.hosting == HOSTING_NAME || !duplicate?(video)
    end
  end

private

  def duplicate? video
    return unless video.author_name&.include?(AUTHOR_NAME)

    sv_videos.any? { |sv_video| sv_video.kind == video.kind }
  end

  def sv_videos
    @sv_videos ||= videos.select { |v| v.hosting == HOSTING_NAME }
  end
end
