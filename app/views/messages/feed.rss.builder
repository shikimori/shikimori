xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title t '.rss.title', nickname: @user.nickname
    xml.description t '.rss.description', nickname: @user.nickname
    xml.link messages_url(type: :notifications)

    @messages.each do |message|
      xml.item do
        xml.title message[:title]
        xml.description (message[:image_url] ? "<img src=\"#{message[:image_url]}\" alt=\"#{message[:linked_name]}\" title=\"#{message[:linked_name]}\" style=\"float: right;\" style=\"max-height: 140;\" />" : '') +
            format_rss_urls(message[:entry].generate_body)
        xml.pubDate message[:pubDate]
        xml.link message[:link]
        xml.guid message[:guid]
      end
    end
  end
end
