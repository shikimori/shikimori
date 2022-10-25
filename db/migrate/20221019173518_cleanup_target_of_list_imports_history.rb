class CleanupTargetOfListImportsHistory < ActiveRecord::Migration[6.1]
  def change
    UserHistory
      .where(action: [UserHistoryAction::ANIME_IMPORT, UserHistoryAction::MANGA_IMPORT])
      .update_all target_id: nil, target_type: nil
  end
end
