class ListImport < ApplicationRecord
  belongs_to :user

  has_attached_file :list

  validates :user, presence: true
  validates_attachment :list,
    presence: true,
    content_type: { content_type: 'application/xml' }

  state_machine :state, initial: :pending do
    state :finished
    state :failed

    event(:finish) { transition pending: :finished }
    event(:terminate) { transition pending: :failed }
  end
end
