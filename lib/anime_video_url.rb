class AnimeVideoUrl
  def initialize url
    @url = url.to_s.strip
  end

  def extract
    if @url =~ /vk.com\/video-\d*_\d*/
      Video.new(url: @url).direct_url
    elsif @url =~ /iframe/
      /iframe src="(.*?)"/.match(@url)[1]
    else
      @url
    end
    rescue
      @url
  end
end
