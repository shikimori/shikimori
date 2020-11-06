class CollectionDecorator < DbEntryDecorator
  instance_cache :cached_links, :entries_sample, :groups, :texts, :bbcode_links

  SAMPLE_LIMIT = 6

  def groups
    cached_links.each_with_object({}) do |link, memo|
      memo[link.group] ||= []
      memo[link.group] << link.send(kind).decorate
    end
  end

  def texts
    cached_links
      .select { |link| link.text.present? }
      .map do |link|
        {
          group_index: groups.keys.index(link.group),
          linked_id: link.linked_id,
          linked_type: link.send(kind).class.base_class.name.downcase,
          text: BbCodes::Text.call(link.text)
        }
      end
  end

  def entries_sample
    if links.size.positive?
      # anime can be deleted but can still be present in collection
      loaded_links.limit(SAMPLE_LIMIT).map { |v| v.send(kind)&.decorate }.compact
    else
      bbcode_entries_sample
    end
  end

  def size
    if links.size.positive?
      links.size
    else
      bbcode_links.size
    end
  end

private

  def cached_links
    # anime can be deleted but can still be present in collection
    loaded_links.select { |v| v.send(kind).present? }
  end

  def loaded_links
    links.includes(kind).order(:id)
  end

  def bbcode_links
    text
      .scan(BbCodes::Tags::DbEntriesTag::REGEXP)
      .map(&:second)
      .flat_map { |v| v.split(',') }
      .uniq
  end

  def bbcode_entries_sample
    kind.classify.constantize
      .where(id: bbcode_links.take(SAMPLE_LIMIT))
      .sort_by { |v| bbcode_links.index v.id }
      .map(&:decorate)
  end
end
