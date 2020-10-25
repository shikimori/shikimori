class AddMissingUserHistoryIndex < ActiveRecord::Migration[5.2]
  ACTIONS = [
    UserHistoryAction::MAL_ANIME_IMPORT,
    UserHistoryAction::AP_ANIME_IMPORT,
    UserHistoryAction::ANIME_HISTORY_CLEAR,
    UserHistoryAction::MAL_MANGA_IMPORT,
    UserHistoryAction::AP_MANGA_IMPORT,
    UserHistoryAction::MANGA_HISTORY_CLEAR
  ]

  def change
    commit_db_transaction
    add_index :user_histories, %i[user_id action],
      where: "action in (#{ACTIONS.map { |v| "'#{v}'" }.join(',')})",
      name: :user_histories_UserDataFetcherBase_latest_import_index,
      algorithm: :concurrently
  end
end
