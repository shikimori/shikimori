class MarkSakuhinidbBideosAsAutoRejected < ActiveRecord::Migration[6.1]
  def up
    Video
      .where(state: 'uploaded')
      .where(uploader_id: BotsService.posters)
      .where.not(anime_id: nil)
      .update_all state: 'auto_rejected'
  end

  def down
    Video
      .where(state: 'auto_rejected')
      .where(uploader_id: BotsService.posters)
      .where.not(anime_id: nil)
      .update_all state: 'uploaded'
  end
end
