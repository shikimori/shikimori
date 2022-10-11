class CleanupMissingSmotretAnimeExternalLinks < ActiveRecord::Migration[6.1]
  def up
    ExternalLink.where(url: 'https://smotret-anime.online/catalog/-1').update_all url: 'NONE'
  end

  def down
    ExternalLink.where(url: 'NONE').update_all url: 'https://smotret-anime.online/catalog/-1'
  end
end
