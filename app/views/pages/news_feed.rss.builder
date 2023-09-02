xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title "News #{Shikimori::DOMAIN}"
    xml.description "News #{Shikimori::DOMAIN}"
    xml.link root_url

    @collection.each do |view|
      xml.item do
        xml.title view.topic_title
        xml.pubDate Time.zone.at(view.created_at.to_i).to_fs(:rfc822)
        xml.description format_rss_urls(view.html_body)
        xml.link view.urls.topic_url(protocol: Shikimori::PROTOCOL)
        xml.guid "entry-#{view.topic.id}"
      end
    end
  end
end
