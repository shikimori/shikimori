comments = Rails.cache.fetch [@resource, :rss, 100] do
  @resource.comments.limit(100).order(id: :desc).reverse
end

xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title @topic_view.topic_title
    xml.description "Topic \"#{@topic_view.topic_title}\" comments #{Shikimori::DOMAIN}"
    xml.link @topic_view.urls.topic_url

    comments.each do |comment|
      xml.item do
        xml.title comment.user.nickname
        xml.description format_rss_urls(comment.html_body)
        xml.pubDate Time.at(comment.created_at.to_i).to_s(:rfc822)
        xml.link "#{@topic_view.urls.topic_url}#comment-#{comment.id}"
        xml.guid "comment-#{comment.id}"
      end
    end
  end
end
