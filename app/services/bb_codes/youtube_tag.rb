class BbCodes::YoutubeTag
  include Singleton

  def format text
    text.gsub /([^"\]]|^)(?:https?:\/\/(?:www\.)?youtube.com\/watch\?(?:feature=player_embedded&(?:amp;)?)?v=([^&\s<>#]+)([^\s<>]+)?)/mi do
      content = $1
      hash = $2
      time = $3[/\bt\b=(\d+)/, 1] if $3
      content + to_html(hash, time)
    end
  end

private
  def to_html hash, time
    video = Video.new url: "http://youtube.com/watch?v=#{hash}"
    @template ||= Slim::Template.new Rails.root.join('app', 'views', 'videos', '_video.html.slim').to_s
    @template.render OpenStruct.new(video: video, time: time)
  end
end
