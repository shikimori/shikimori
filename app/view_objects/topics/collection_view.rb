class Topics::CollectionView < Topics::View
  def container_class
    super 'b-collection-topic'
  end

  def minified?
    is_preview || is_mini
  end

  def poster is_2x
    @topic.user.avatar_url is_2x ? 80 : 48
  end

  def url options = {}
    if is_mini
      canonical_url
    else
      super
    end
  end

  def canonical_url
    h.collection_url collection
  end

  def html_body
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

  def collection_size
    collection.links.size
  end

private

  def collection_links_bb_code
    ids = collection.links.limit(6).pluck(:linked_id)
    tag_type = collection.kind.pluralize
    "[#{tag_type} ids=#{ids.join ','} class=collection-row]"
  end

  def collection
    @topic.linked
  end
end
