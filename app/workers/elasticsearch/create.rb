class Elasticsearch::Create < Elasticsearch::Destroy
  METHOD = :post

  def perform entry_id, entry_type
    entry = entry_type.constantize.find_by id: entry_id
    sync entry if entry
  end

  def sync entry
    klass = entry.is_a?(Topic) ? Topic : entry.class
    type = klass.name.pluralize.downcase

    Elasticsearch::ClientOld.instance.send(
      self.class::METHOD,
      "#{INDEX}_#{type}/#{type}/#{entry.id}",
      "Elasticsearch::Data::#{klass.name}".constantize.call(entry)
    )
  end
end
