class AnimeVideoUrl
  def initialize url
    @url = url.to_s.strip
  end

  def extract
    if @url =~ /iframe [^>]*src="(.*?)"/
      $1
    else
      VideoExtractor.fetch(@url).try(:player_url) || @url
    end
  end
end
