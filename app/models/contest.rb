# frozen_string_literal: true

class Contest < ApplicationRecord
  include AASM
  include TopicsConcern

  MINIMUM_MEMBERS = 5
  MAXIMUM_MEMBERS = 196

  belongs_to :user

  has_many :links,
    class_name: 'ContestLink',
    dependent: :destroy

  has_many :rounds, -> { order %i[number additional id] },
    class_name: 'ContestRound',
    inverse_of: :contest,
    dependent: :destroy

  has_many :winners, -> { order :position },
    class_name: 'ContestWinner',
    inverse_of: :contest,
    dependent: :destroy
  has_many :anime_winners,
    through: :winners,
    source: :item,
    source_type: 'Anime'
  has_many :character_winners,
    through: :winners,
    source: :item,
    source_type: 'Character'

  has_many :animes, -> { order :name },
    through: :links,
    source: :linked,
    source_type: 'Anime'

  has_many :characters, -> { order :name },
    through: :links,
    source: :linked,
    source_type: 'Character'

  has_many :suggestions,
    class_name: 'ContestSuggestion',
    dependent: :destroy

  enumerize :member_type,
    in: Types::Contest::MemberType.values,
    predicates: true
  enumerize :strategy_type,
    in: Types::Contest::StrategyType.values,
    predicates: true
  enumerize :user_vote_key, in: Types::Contest::UserVoteKey.values

  validates :title_ru, presence: true
  validates :description_ru, :description_en, length: { maximum: 32_768 }
  validates :started_on, :user_vote_key, :strategy_type, :member_type,
    presence: true
  validates :matches_interval, :match_duration, :matches_per_round,
    numericality: { greater_than: 0 }, presence: true

  aasm column: 'state', create_scopes: false do # rubocop:disable BlockLength
    state Types::Contest::State[:created], initial: true
    state Types::Contest::State[:proposing]
    state Types::Contest::State[:started]
    state Types::Contest::State[:finished]

    event :propose do
      transitions(
        from: Types::Contest::State[:created],
        to: Types::Contest::State[:proposing],
        success: :generate_missing_topics
      )
    end
    event :stop_propose do
      transitions(
        from: Types::Contest::State[:proposing],
        to: Types::Contest::State[:created]
      )
    end
    event :start do
      transitions(
        from: [
          Types::Contest::State[:created],
          Types::Contest::State[:proposing]
        ],
        to: Types::Contest::State[:started],
        success: :generate_missing_topics,
        if: -> { links.count.between? MINIMUM_MEMBERS, MAXIMUM_MEMBERS }
      )
    end
    event :finish do
      transitions(
        from: Types::Contest::State[:started],
        to: Types::Contest::State[:finished],
        if: -> { rounds.any? && rounds.all?(&:finished?) }
      )
    end
  end

  def current_round
    if finished?
      rounds.last
    else
      rounds.find(&:started?) ||
        rounds.reject(&:finished?).first ||
        rounds.first
    end
  end

  def defeated_by entry, round
    @defeated ||= {}
    @defeated["#{entry.id}-#{round.id}"] ||= ContestMatch
      .where(
        round_id: rounds.map(&:id).select { |v| v <= round.id },
        state: 'finished',
        winner_id: entry.id
      )
      .includes(:left, :right)
      .order(:id)
      .map { |vote| vote.winner_id == vote.left_id ? vote.right : vote.left }
      .compact
  end

  def to_param
    "#{id}-#{name.permalinked}"
  end

  def title
    # I18n.russian? ? title_ru : title_en.presence || title_ru
    title_ru
  end

  def name
    title
  end

  def strategy
    @strategy ||=
      if double_elimination?
        Contest::DoubleEliminationStrategy.new self
      elsif play_off?
        Contest::PlayOffStrategy.new self
      else
        Contest::SwissStrategy.new self
      end
  end

  def members
    anime? ? animes : characters
  end

  def member_klass
    member_type.classify.constantize
  end

  def topic_user
    user
  end

private

  def generate_missing_topics
    generate_topic if topics.none?
  end
end
