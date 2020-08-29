class AnimeVideoDecorator < BaseDecorator
  # NOTE: используется в ./app/views/versions/_anime_video.html.slim
  def name
    "episode ##{episode} #{anime.name}"
  end
end
