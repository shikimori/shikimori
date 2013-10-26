xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title 'Новости shikimori.org'
    xml.description 'Аниме новости и овости сайта shikimori.org'
    xml.link root_url

    @topics.each do |topic|
      xml.item do
        xml.title topic.title
        xml.description format_rss_urls(BbCodeService.instance.format_comment topic.text)
        xml.pubDate Time.at(topic.updated_at.to_i)
        xml.link topic_url(topic)
        xml.guid topic.guid
      end
    end
  end
end
