class CollectionDecorator < DbEntryDecorator
  instance_cache :cached_links, :entries_sample, :groups, :texts

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
      .each_with_object({}) do |link, memo|
        memo[link.linked_id] = BbCodeFormatter.instance.format_comment link.text
      end
  end

  def entries_sample
    loaded_links.limit(SAMPLE_LIMIT).map { |v| v.send(kind).decorate }
  end

  def size
    links.size
  end

private

  def cached_links
    loaded_links
  end

  def loaded_links
    links.includes(kind).order(:id)
  end
end
