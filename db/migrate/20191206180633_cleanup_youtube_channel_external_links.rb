class CleanupYoutubeChannelExternalLinks < ActiveRecord::Migration[5.2]
  def change
    ExternalLink.where(kind: 'youtube_channel').delete_all
  end
end
