class Topics::CollectionView < Topics::View
  def poster is_2x
    @topic.user.avatar_url is_2x ? 80 : 48
  end

  # def html_body
    # if topic.linked.text.present?
      # Rails.cache.fetch [topic.linked, :html] do
        # BbCodeFormatter.instance.format_comment(topic.linked.text)
      # end
    # else
      # super
    # end
  # end
end
