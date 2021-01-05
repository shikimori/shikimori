class Topics::CollectionView < Topics::UserContentView
  instance_cache :collection
  delegate :unpublished?, to: :collection

  def container_classes
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
    if preview?
      preview_html
    else
      collection_html
    end
  end

  def action_tag
    OpenStruct.new(
      type: 'collection',
      text: Collection.model_name.human.downcase
    )
  end

  def collection
    @topic.linked.decorate
  end

private

  def preview_html
    h.render(
      partial: 'collections/preview',
      formats: :html, # for /forum.rss
      locals: { collection: collection, topic_view: self }
    )
  end

  def collection_html
    # without specifying format it won't be rendered in api (https://shikimori.one/api/topics/223789)
    h.render(
      partial: 'collections/collection',
      object: collection,
      formats: :html
    )
  end
end
