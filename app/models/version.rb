# TODO : Перед откатом хорошо бы проверять возможность отката текущей версии (если {:episode=>[1, 2]}, то episode должен быть 2). @blackchestnut
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
      transition [:pending, :accepted_pending] => :accepted
    end

    before_transition [:pending, :accepted_pending] => :rejected do |version, transition|
      rollback_params = version.item_diff.inject({}) do |mem, v|
        mem[v.first] = v.second.first
        mem
      end
      version.item.update rollback_params
    end

    event :reject do
      transition [:pending, :accepted_pending] => :rejected
    end
  end
end
