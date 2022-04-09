class ListImport < ApplicationRecord
  include AntispamConcern
  include Translation

  antispam per_day: 10, user_id_key: :user_id

  ERROR_EXCEPTION = 'error_exception'
  ERROR_BROKEN_FILE = 'broken_file'
  ERROR_EMPTY_LIST = 'empty_list'
  ERROR_MISMATCHED_LIST_TYPE = 'mismatched_list_type'
  ERROR_MISSING_FIELDS = 'missing_fields'

  belongs_to :user, touch: true

  enumerize :list_type,
    in: Types::ListImport::ListType.values,
    predicates: true

  enumerize :duplicate_policy,
    in: Types::ListImport::DuplicatePolicy.values,
    predicates: { prefix: true }

  # state_machine :state, initial: :pending do
  #   state :pending
  #   state :finished
  #   state :failed
  #
  #   event(:finish) { transition pending: :finished }
  #   event(:to_failed) { transition pending: :failed }
  # end

  has_attached_file :list

  validates :user, presence: true
  validates_attachment :list,
    presence: true,
    content_type: {
      content_type: %w[
        application/xml
        application/json
        application/gzip
        text/plain
      ]
    },
    size: { in: 0..(15.megabytes) },
    if: :pending?

  after_create :schedule_worker

  def name
    i18n_t 'name', id: id, filename: list_file_name
  end

private

  def schedule_worker
    ListImports::ImportWorker.perform_async id
  end
end
