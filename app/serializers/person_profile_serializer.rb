class PersonProfileSerializer < PersonSerializer
  attributes :japanese, :job_title, :birth_on, :deceased_on, :website, :groupped_roles,
    :roles, :works, :topic_id,
    :person_favoured, :producer, :producer_favoured,
    :mangaka, :mangaka_favoured, :seyu, :seyu_favoured,
    :updated_at,
    :thread_id, :birthday

  def roles
    object.character_works.map do |work|
      {
        characters: work[:characters].map { |v| CharacterSerializer.new v },
        animes: work[:animes].map { |v| AnimeSerializer.new v }
      }
    end
  end

  def works
    object.works.map do |work|
      {
        anime: work.object.is_a?(Anime) ? AnimeSerializer.new(work) : nil,
        manga: work.object.is_a?(Manga) ? MangaSerializer.new(work) : nil,
        role: work.formatted_role
      }
    end
  end

  def groupped_roles
    object.grouped_roles
  end

  # TODO: deprecated
  def thread_id
    object.maybe_topic.id
  end

  # TODO: deprecated
  def birthday
    object.birth_on
  end

  def topic_id
    object.maybe_topic.id
  end

  def person_favoured
    object.person_favoured?
  end

  def producer
    object.producer?
  end

  def producer_favoured
    object.producer_favoured?
  end

  def mangaka
    object.mangaka?
  end

  def mangaka_favoured
    object.mangaka_favoured?
  end

  def seyu
    object.seyu?
  end

  def seyu_favoured
    object.seyu_favoured?
  end
end
