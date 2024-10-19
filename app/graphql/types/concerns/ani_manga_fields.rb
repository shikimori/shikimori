module Types::Concerns::AniMangaFields
  extend ActiveSupport::Concern

  CHRONOLOGY_ERROR = 'Chronology can be fetched only for a single entity. ' \
    'Set `limit: 1` in query arguments.'

  included do |_klass|
    field :license_name_ru, String
    field :english, String
    field :franchise, String, description: 'Franchise name'
    field :score, Float
    field :aired_on, Types::Scalars::IncompleteDate
    field :released_on, Types::Scalars::IncompleteDate

    field :licensors, [String]

    field :is_censored, Boolean
    def is_censored # rubocop:disable Naming/PredicateName
      object.censored?
    end

    field :genres, [Types::GenreType]
    def genres
      object.genres_v2
    end

    field :external_links, [Types::ExternalLinkType], complexity: 10
    def external_links
      decorated_object.available_external_links
    end

    field :character_roles, [Types::CharacterRoleType], complexity: 10
    def character_roles
      object.person_roles.select(&:character_id).select { |v| v.character.present? }
    end

    field :person_roles, [Types::PersonRoleType], complexity: 10
    def person_roles
      object.person_roles.select(&:person_id).select { |v| v.person.present? }
    end

    field :related, [Types::RelatedType], complexity: 10

    field :scores_stats, [Types::ScoreStatType]
    def scores_stats
      (object.stats&.scores_stats || []).map do |entry|
        {
          score: entry[0],
          count: entry[1]
        }
      end
    end

    field :statuses_stats, [Types::StatusStatType]
    def statuses_stats
      (object.stats&.list_stats || []).map do |entry|
        {
          status: entry[0],
          count: entry[1]
        }
      end
    end

    def chronology
      context[:chronology_counter] ||= 0
      context[:chronology_counter] += 1
      raise ArgumentError, CHRONOLOGY_ERROR if context[:chronology_counter] > 1

      Animes::ChronologyQuery.new(object).fetch.map(&:decorate)
    end

    field :opengraph_image_url, String, null: true
  end
end
