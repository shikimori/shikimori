xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title t('comments.show.user_comment', id: @view.comment.id, user: @view.user.nickname)

    xml.description format_rss_urls(@view.comment.html_body)
    xml.link comment_url(@view.comment)

    @view.comments.each do |comment|
      xml.item do
        xml.title comment.user.nickname
        xml.description format_rss_urls(comment.html_body)
        xml.pubDate Time.at(comment.created_at.to_i).to_s(:rfc822)
        xml.link comment_url(comment)
        xml.guid "comment-#{comment.id}"
      end
    end
  end
end
