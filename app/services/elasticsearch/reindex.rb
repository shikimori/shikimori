class Elasticsearch::Reindex < ServiceObjectBase
  INDEX = Elasticsearch::Config::INDEX
  CACHE_KEY = 'elastic_reindex'

  def call
    client.delete INDEX
    client.put INDEX, Elasticsearch::Config.instance[:node]

    animes
    mangas
    characters
    people
    users

    Rails.cache.write CACHE_KEY, Time.zone.now
  end

  def self.time
    Rails.cache.fetch(CACHE_KEY) { Time.zone.now }
  end

private

  def animes
    Anime.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def mangas
    Manga.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def characters
    Character.find_each do |entry|
      Elasticsearch::Create.new.sync entry
    end
  end

  def people
    Person.find_each do |entry|
      client.post(
        "#{INDEX}/person/#{entry.id}", Elasticsearch::Data::Person.call(entry)
      )
    end
  end

  def users
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
