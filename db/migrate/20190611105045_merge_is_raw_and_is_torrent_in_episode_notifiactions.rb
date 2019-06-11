class MergeIsRawAndIsTorrentInEpisodeNotifiactions < ActiveRecord::Migration[5.2]
  def change
    EpisodeNotification
      .where(is_unknown: true)
      .update_all is_raw: true

    EpisodeNotification
      .where(is_torrent: true)
      .update_all is_raw: true
  end
end
