xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title @page_title.last
    # xml.description @forum[:description]
    xml.link forum_url(forum: @view.forum.try(:permalink))

    @view.topics.each do |view|
      xml.item do
        xml.title view.topic_title
        xml.pubDate Time.at(view.created_at.to_i).to_s(:rfc822)
        xml.description format_rss_urls(view.html_body)
        #xml.description format_rss_urls(BbCodeFormatter.instance.format_comment topic.text)
        xml.link view.urls.topic_url
        xml.guid view.topic.guid
      end
    end
  end
end
