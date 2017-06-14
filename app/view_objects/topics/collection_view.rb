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

  def footer_vote?
    !preview?
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

  def collection
    @topic.linked.decorate
  end

private

  def preview_html
    h.render(
      partial: 'collections/preview',
      locals: { collection: collection, topic_view: self }
    )
  end

  def collection_html
    h.render collection
  end

  def results_html
    h.render 'reviews/votes', review: collection
  end
end
