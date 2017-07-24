class ListImport < ApplicationRecord
  belongs_to :user

  has_attached_file :list

  enumerize :list_type,
    in: Types::ListImport::ListType.values,
    predicates: { prefix: true }

  enumerize :duplicate_policy,
    in: Types::ListImport::DuplicatePolicy.values,
    predicates: { prefix: true }

  validates :user, presence: true
  validates_attachment :list,
    presence: true,
    content_type: { content_type: %w[application/xml application/json] }

  state_machine :state, initial: :pending do
    state :finished
    state :failed

    event(:finish) { transition pending: :finished }
    event(:terminate) { transition pending: :failed }
  end
end
