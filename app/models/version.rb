# TODO: Перед откатом хорошо бы проверять возможность отката текущей версии (если {:episode=>[1, 2]}, то episode должен быть 2). @blackchestnut
class Version < ActiveRecord::Base
  belongs_to :user
  belongs_to :moderator, class_name: User
  belongs_to :item, polymorphic: true

  validates :item, :item_diff, presence: true

  state_machine :state, initial: :pending do
    state :accepted
    state :auto_accepted
    state :rejected

    state :taken
    state :deleted

    event :accept do
      transition [:pending] => :accepted
    end
    event :take do
      transition [:pending] => :taken
    end
    event :reject do
      transition [:pending, :accepted_pending] => :rejected
    end

    event :to_deleted do
      transition [:pending] => :deleted
    end

    before_transition [:pending] => [:accepted, :taken] do |version, transition|
      version.apply_changes!
    end

    before_transition [:accepted_pending] => :rejected do |version, transition|
      version.rollback_changes!
    end

    before_transition [:pending] => [:accepted, :taken, :rejected, :deleted] do |version, transition|
      version.update moderator: transition.args.first if transition.args.first
    end
  end

  def apply_changes!
    attributes = item_diff.each_with_object({}) do |(field,changes), memo|
      memo[field] = changes.second
      changes[0] = current_value field
    end

    item.update! attributes
    save!
  end

  def rollback_changes!
    attributes = item_diff.each_with_object({}) do |(field,changes), memo|
      memo[field] = changes.first
    end

    item.update! attributes
  end

  def current_value field
    item.send field
  end
end
