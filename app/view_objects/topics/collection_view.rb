class Topics::CollectionView < Topics::UserContentView
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

  def offtopic_tag
    I18n.t 'markers.offtopic' if collection.rejected?
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
    h.render collection
  end

  def results_html
    h.render 'topics/reviews/votes_count', review: collection
  end
end
