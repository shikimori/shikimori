xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title @section[:name]
    xml.description @section[:description]
    xml.link section_url(section: @section[:permalink])

    @collection.each do |view|
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
