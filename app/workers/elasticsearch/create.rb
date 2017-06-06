class Elasticsearch::Create < Elasticsearch::Destroy
  METHOD = :post

  def perform entry_id, entry_type
    entry = entry_type.constantize.find_by id: entry_id
    sync entry if entry
  end

  def sync entry
    type = entry.class.name.pluralize.downcase

    Elasticsearch::Client.instance.send(
      self.class::METHOD,
      "#{INDEX}_#{type}/#{type}/#{entry.id}",
      "Elasticsearch::Data::#{entry.class.name}".constantize.call(entry)
    )
  end
end
