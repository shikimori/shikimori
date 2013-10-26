comments = Rails.cache.fetch [@topic, :rss, 100] do
  @topic.comments(nil).limit(100).order { id.desc }.reverse
end

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @h1
    xml.description "Комментарии топика \"#{@h1}\" на Шикимори"
    xml.link section_topic_url(section: @section[:permalink], topic: @topic)

    comments.each do |comment|
      xml.item do
        xml.title comment.user.nickname
        xml.description format_rss_urls(comment.html_body)
        xml.pubDate Time.at(comment.created_at.to_i).to_s(:rfc822)
        xml.link "%s#comment-%d" % [
            section_topic_url(section: @section[:permalink], topic: @topic),
            comment.id
          ]
        xml.guid comment.guid
      end
    end
  end
end
