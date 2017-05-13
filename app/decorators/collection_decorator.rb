class CollectionDecorator < DbEntryDecorator
  instance_cache :loaded_links, :groups, :texts

  def groups
    loaded_links.each_with_object({}) do |link, memo|
      memo[link.group] ||= []
      memo[link.group] << link.send(kind).decorate
    end
  end

  def texts
    loaded_links
      .select { |link| link.text.present? }
      .each_with_object({}) do |link, memo|
        memo[link.linked_id] = BbCodeFormatter.instance.format_comment link.text
      end
  end

private

  def loaded_links
    links.includes(kind).order(:id).to_a
  end
end
