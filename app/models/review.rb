# сущность обзора аниме или манги
class Review < ActiveRecord::Base
  include Antispam
  include Moderatable
  include PermissionsPolicy
  include Viewable

  acts_as_voteable

  belongs_to :target, polymorphic: true
  belongs_to :user
  belongs_to :approver, class_name: User.name, foreign_key: :approver_id

  has_one :thread, -> { where linked_type: Review.name },
    class_name: ReviewComment.name,
    foreign_key: :linked_id,
    dependent: :destroy

  validates_presence_of :user, :target
  validates :text, length: { minimum: 1000, too_short: "слишком короткий (минимум 1000 знаков)" }
  validates_inclusion_of :storyline, in: 1..10, message: "не имеет оценки"
  validates_inclusion_of :animation, in: 1..10, message: "не имеет оценки"
  validates_inclusion_of :characters, in: 1..10, message: "не имеют оценки"
  validates_inclusion_of :music, in: 1..10, message: "не имеет оценки", if: -> { self.target_type != Manga.name  }
  validates_inclusion_of :overall, in: 1..10, message: "не задана"

  after_create :create_thread

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
    end
  end

  # создание ReviewComment для элемента сразу после создания
  def create_thread
    ReviewComment.create!(
      linked_id: self.id,
      linked_type: self.class.name,
      user: user,
      title: "Обзор #{target.class == Anime ? 'аниме' : 'манги'} #{entry.name}",
      created_at: created_at,
      updated_at: updated_at,
    )
  end

  # хз что это за хрень и почему ReviewComment.first.linked.target возвращает сам обзор. я так и не понял
  def entry
    @entry ||= Object.const_get(target_type).find(target_id)
  end

  def body
    text
  end

  def votes_text
    if votes_for == votes_count
      "#{votes_count} #{Russian.p(votes_count, 'пользователь', 'пользователя', 'пользователей')} #{votes_for > 1 ? 'посчитали' : 'посчитал'} этот обзор полезным"
    else
      #"#{votes_for} из #{votes_count} #{Russian.p(votes_count, 'пользователя', 'пользователей', 'пользователей')} #{Russian.p(votes_for == 0 ? 8 : votes_for, 'посчитал', 'посчитали', 'посчитало')} этот обзор полезным"
      "#{votes_for} из #{votes_count} #{Russian.p(votes_count, 'пользователя', 'пользователей', 'пользователей')} #{votes_for > 1 ? 'посчитали' : 'посчитал'} этот обзор полезным"
    end
  end

  def to_offtopic!
    thread.class.record_timestamps = false
    thread.update_column :section_id, Section::OfftopicId
    thread.class.record_timestamps = true
  end

  def self.has_changes?
    pending.count > 0
  end
end
