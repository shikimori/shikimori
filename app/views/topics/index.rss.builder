xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title "#{og.headline} #{Shikimori::DOMAIN}"
    # xml.description @forum[:description]
    xml.link forum_url(forum: @forums_view.forum.try(:permalink))

    @forums_view.topic_views.each do |topic_view|
      xml.item do
        xml.title topic_view.topic_title
        xml.pubDate Time.zone.at(topic_view.created_at.to_i).to_fs(:rfc822)
        xml.description format_rss_urls(topic_view.html_body)
        xml.link topic_view.urls.topic_url
        xml.guid "entry-#{topic_view.topic.id}"
      end
    end
  end
end
