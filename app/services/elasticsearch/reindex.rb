class Elasticsearch::Reindex
  method_object :types

  INDEX = Elasticsearch::Config::INDEX
  CACHE_KEY = 'elastic_reindex'

  ALL_TYPES = %i[anime manga ranobe character person user club collection]

  def call
    remade_index if @types == ALL_TYPES

    @types.each do |type|
      respond_to?("fill_#{type}") ? send("fill_#{type}") : fill_type(type)
    end

    Rails.cache.write CACHE_KEY, Time.zone.now
  end

  def self.time
    Rails.cache.fetch(CACHE_KEY) { Time.zone.now }
  end

private

  def remade_index
    client.delete INDEX
    client.put INDEX, Elasticsearch::Config.instance[:node]
  end

  def fill_type type
    type.to_s.classify.constantize.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def fill_manga
    Manga.where.not(kind: Ranobe::KIND).find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def fill_ranobe
    Ranobe.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def client
    Elasticsearch::Client.instance
  end
end
