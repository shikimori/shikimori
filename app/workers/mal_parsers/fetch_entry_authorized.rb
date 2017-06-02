class MalParsers::FetchEntryAuthorized
  include Sidekiq::Worker

  sidekiq_options(
    unique: :while_executing,
    unique_args: ->(_args) { 'only_one_task' },
    queue: :mal_parsers
  )

  def perform entry_id, entry_type
    "Import::#{entry_type}".constantize.call parsed_data(entry_id, entry_type)
    update_authorized_imported_at! entry_id, entry_type
  end

private

  def parsed_data entry_id, entry_type
    "MalParsers::#{entry_type}Authorized".constantize.call entry_id
  end

  def update_authorized_imported_at! entry_id, entry_type
    entry_type.constantize
      .find(entry_id)
      .update!(authorized_imported_at: Time.zone.now)
  end
end
