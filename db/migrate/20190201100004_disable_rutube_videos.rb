class DisableRutubeVideos < ActiveRecord::Migration[5.2]
  def up
    AnimeVideo
      .where(state: %i[working uploaded])
      .where("url like '%rutube.ru/%'")
      .each(&:ban!)
  end
end
