xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title @section[:name]
    xml.description @section[:description]
    xml.link section_url(section: @section[:permalink])

    @topics.each do |topic|
      xml.item do
        xml.title topic.title
        xml.pubDate Time.at(topic.created_at.to_i).to_s(:rfc822)
        xml.description format_rss_urls(topic.html_body)
        #xml.description format_rss_urls(BbCodeFormatter.instance.format_comment topic.text)
        xml.link topic_url(topic)
        xml.guid topic.guid
      end
    end
  end
end
