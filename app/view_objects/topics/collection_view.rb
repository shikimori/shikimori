class Topics::CollectionView < Topics::UserContentView
  instance_cache :collection

  def container_classes
    super 'b-collection-topic'
  end

  def minified?
    is_preview || is_mini
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
    tags = Array(super)

    unless collection.published?
      tags << OpenStruct.new(
        type: "#{collection.state_name}-collection",
        text: collection.human_state_name.downcase
      )
    end

    tags << OpenStruct.new(
      type: 'collection',
      text: Collection.model_name.human.downcase
    )

    tags
  end

  def offtopic_tag
    super if collection.published?
  end

  def collection
    @topic.linked.decorate
  end

  def prebody?
    tags.any?
  end

  def linked_in_poster?
    false
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
