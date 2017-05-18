class Elasticsearch::Reindex < ServiceObjectBase
  INDEX = Elasticsearch::Config::INDEX
  CACHE_KEY = 'elastic_reindex'

  TYPES = %i[anime manga ranobe character person user]

  def call
    client.delete INDEX
    client.put INDEX, Elasticsearch::Config.instance[:node]

    TYPES.each { |type| send type }

    Rails.cache.write CACHE_KEY, Time.zone.now
  end

  def self.time
    Rails.cache.fetch(CACHE_KEY) { Time.zone.now }
  end

private

  def anime
    Anime.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def manga
    Manga.where.not(kind: Ranobe::KIND).find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def ranobe
    Ranobe.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def character
    Character.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def person
    Person.find_each do |entry|
      client.post(
        "#{INDEX}/person/#{entry.id}", Elasticsearch::Data::Person.call(entry)
      )
    end
  end

  def user
    User.find_each do |entry|
      client.post(
        "#{INDEX}/user/#{entry.id}", Elasticsearch::Data::User.call(entry)
      )
    end
  end

  def client
    Elasticsearch::Client.instance
  end
end
