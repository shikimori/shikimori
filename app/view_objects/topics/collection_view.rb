class Topics::CollectionView < Topics::View
  def container_class
    super 'b-collection-topic'
  end

  def poster is_2x
    @topic.user.avatar_url is_2x ? 80 : 48
  end

  def html_body
    # if topic.linked.text.present?
      # Rails.cache.fetch [topic.linked, :html] do
        # BbCodeFormatter.instance.format_comment(topic.linked.text)
      # end
    # else
      # super
    # end
    Rails.cache.fetch [:body, collection] do
      BbCodeFormatter.instance.format_comment(
        collection_links_bb_code
      )
    end
  end

  # def html_footer
  # end

  def action_tag
    OpenStruct.new(
      type: 'collection',
      text: Collection.model_name.human.downcase
    )
  end

private

  def collection_links_bb_code
    ids = collection.links.limit(8).pluck(:linked_id)
    tag_type = collection.kind.pluralize
    "[#{tag_type} ids=#{ids.join ','} columns=8]"
  end

  def collection
    @topic.linked
  end
end
