class FixSmotretanimeExternalLinks < ActiveRecord::Migration[5.2]
  def change
    ExternalLink.where("url like 'https://smotretanime.ru%'").each do |external_link|
      external_link.update!(
        url: external_link.url.gsub('https://smotretanime.ru', 'https://smotret-anime.online')
      )
    end
  end
end
