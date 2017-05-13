class Topics::CollectionView < Topics::View
  instance_cache :collection

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

  def show_body?
    true
  end

  def html_body
    if preview?
      preview_html
    else
      results_html + collection_html
    end
  end

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

  def preview_html
    ids = collection.links.limit(6).pluck(:linked_id)
    tag_type = collection.kind.pluralize

    BbCodeFormatter.instance.format_comment(
      "[#{tag_type} ids=#{ids.join ','} class=collection-row]"
    )
  end

  def collection_html
    h.render collection
  end

  def results_html
    h.render 'reviews/votes', review: collection
  end

  def collection
    @topic.linked.decorate
  end
end
