class CleanupBrokenKageLinks < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        ExternalLink
          .where(
            url: 'http://fansubs.ru/base.php?id=16',
            source: 'smotret_anime'
          ).find_each do |external_link|
            external_link.entry.external_links
              .where(url: 'NONE', kind: 'kage_project')
              .destroy_all
            external_link.destroy
          end
      end
    end
  end
end
