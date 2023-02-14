# class MalParsers::FetchEntryAuthorized
#   include Sidekiq::Worker
#   sidekiq_options(
#     queue: :mal_parsers,
#     retry_in: 0
#   )
#
#   def perform entry_id, entry_type
#     "DbImport::#{entry_type}".constantize.call parsed_data(entry_id, entry_type)
#     update_authorized_imported_at! entry_id, entry_type
#   rescue InvalidIdError
#     update_authorized_imported_at! entry_id, entry_type
#   rescue RedisMutex::LockError, *Network::FaradayGet::NET_ERRORS
#     MalParsers::FetchEntryAuthorized.perform_in 30.minutes, entry_id, entry_type
#   end
#
# private
#
#   def parsed_data entry_id, entry_type
#     "MalParsers::#{entry_type}Authorized".constantize.call entry_id
#   end
#
#   def update_authorized_imported_at! entry_id, entry_type
#     entry(entry_id, entry_type).update! authorized_imported_at: Time.zone.now
#   end
#
#   def entry entry_id, entry_type
#     entry_type.constantize.find(entry_id)
#   end
# end
