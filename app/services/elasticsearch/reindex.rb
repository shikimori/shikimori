class Elasticsearch::Reindex
  method_object :types

  CACHE_KEY = 'elastic_reindex'

  TYPES = %i[anime manga ranobe character person user club collection topic]

  def call
    Array(@types).each do |type|
      respond_to?("fill_#{type}") ? send("fill_#{type}") : fill_type(type)
    end
  end

  def self.time type
    Rails.cache.fetch("#{CACHE_KEY}_#{type}") { Time.zone.now }
  end

private

  def remake_index type
    client.delete "#{Elasticsearch::Config::INDEX}_#{type.to_s.pluralize}"
    client.put "#{Elasticsearch::Config::INDEX}_#{type.to_s.pluralize}", {
      settings: {
        analysis: Elasticsearch::Config.instance[:analysis]
      },
      mappings: {
        type.to_s.pluralize.to_sym =>
          Elasticsearch::Config.instance[:mappings][type.to_s.pluralize.to_sym]
      }
    }
  end

  def update_cache type
    Rails.cache.write "#{CACHE_KEY}_#{type}", Time.zone.now
  end

  def fill_type type
    remake_index type
    type.to_s.classify.constantize.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
    update_cache type
  end

  def fill_manga
    remake_index :manga
    Manga.where.not(kind: Ranobe::KIND).find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
    update_cache :manga
  end

  def fill_ranobe
    remake_index :ranobe
    Ranobe.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
    update_cache :ranobe
  end

  def client
    Elasticsearch::Client.instance
  end
end
