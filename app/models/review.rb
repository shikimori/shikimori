# frozen_string_literal: true

class Review < ActiveRecord::Base
  include Antispam
  include Moderatable
  include TopicsConcern

  acts_as_voteable

  MINIMUM_LENGTH = 3000

  belongs_to :target, polymorphic: true, touch: true
  belongs_to :user
  belongs_to :approver, class_name: User.name, foreign_key: :approver_id

  validates :user, :target, presence: true
  validates :text,
    length: {
      minimum: MINIMUM_LENGTH,
      too_short: "слишком короткий (минимум #{MINIMUM_LENGTH} знаков)"
    },
    if: -> { changes['text'] }
  validates :locale, presence: true

  enumerize :locale, in: %i(ru en), predicates: { prefix: true }

  scope :pending, -> { where state: 'pending' }
  scope :visible, -> { where state: ['pending', 'accepted'] }

  state_machine :state, initial: :pending do
    state :pending
    state :accepted do
      validates :approver, presence: true
    end
    state :rejected do
      validates :approver, presence: true
    end

    event :accept do
      transition pending: :accepted
    end

    event :reject do
      transition pending: :rejected
    end

    before_transition pending: :accepted do |review, transition|
      review.approver = transition.args.first
    end

    before_transition pending: :rejected do |review, transition|
      review.approver = transition.args.first
      review.to_offtopic!

      Message.create_wo_antispam!(
        from_id: review.approver_id,
        to_id: review.user_id,
        kind: MessageType::Notification,
        body: "Ваша [entry=#{review.topic(review.locale).id}]реценция[/entry] перенесена в оффтоп" +
          (transition.args.second ?
           " по причине: [quote=#{review.approver.nickname}]#{transition.args.second}[/quote]" : '')
      )
    end
  end

  def topic_user
    user
  end

  # хз что это за хрень и почему ReviewComment.first.linked.target
  # возвращает сам обзор. я так и не понял
  def entry
    @entry ||= Object.const_get(target_type).find(target_id)
  end

  def body
    text
  end

  # TODO: move to view object
  def votes_text
    if votes_for == votes_count
      <<-TEXT.squish
        #{votes_count}
        #{Russian.p votes_count, 'пользователь', 'пользователя', 'пользователей'}
        #{Russian.p votes_for, 'посчитал', 'посчитали', 'посчитали'}
        этот обзор полезным
      TEXT
    else
      <<-TEXT.squish
        #{votes_for} из #{votes_count}
        #{Russian.p votes_count, 'пользователя', 'пользователей', 'пользователей'}
        #{Russian.p votes_for, 'посчитал', 'посчитали', 'посчитали'}
        этот обзор полезным
      TEXT
    end
  end

  def to_offtopic!
    topic(locale).update_column :forum_id, Forum::OFFTOPIC_ID
  end
end
