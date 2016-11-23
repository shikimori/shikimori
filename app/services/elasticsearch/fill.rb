class Elasticsearch::Fill < ServiceObjectBase
  pattr_initialize :scope

  def call
    client.delete 'names'
    client.put 'names', Elasticsearch::Config.instance[type]

    scope.find_each do |entry|
      client.post "names/#{type}/#{entry.id}",
        names: (
          [entry.name, entry.russian] +
          entry.english + entry.japanese + entry.synonyms
        ).compact
    end
  end

private

  def type
    @scope.model.name.downcase.to_sym
  end

  def client
    @client ||= Elasticsearch::Client.new
  end
end
