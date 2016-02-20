class BbCodes::VideoTag
  include Singleton
  REGEXP = /
    \[
      video=(?<id>\d+)
    \]
  /xi

  def format text
    text.gsub REGEXP do |matched|
      video = Video.find_by id: $~[:id]

      if video
        html_for video
      else
        matched
      end
    end
  end

private

  def html_for video
    @template = Slim::Template.new Rails.root.join('app', 'views', 'videos', '_video.html.slim').to_s
    @template.render OpenStruct.new(video: video)
  end
end
