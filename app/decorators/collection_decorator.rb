class CollectionDecorator < DbEntryDecorator
  instance_cache :groups

  def groups
    links
      .includes(kind)
      .each_with_object({}) do |link, memo|
        memo[link.group] ||= []
        memo[link.group] << link.send(kind).decorate
      end
  end
end
