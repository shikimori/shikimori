class MigrateRussianUserChanges < ActiveRecord::Migration
  def up
    UserChange.
      where(column: 'russian').
      each do |user_change|
        Version.create(
          user_id: user_change.user_id,
          state: user_change.status.downcase,
          item_id: user_change.item_id,
          item_type: user_change.model,
          item_diff: {
            'russian' => [
              user_change.prior,
              user_change.value,
            ]
          },
          moderator_id: user_change.approver_id,
          reason: user_change.reason,
          created_at: user_change.created_at,
        )
        user_change
      end.
      each(&:destroy)
  end

  def down
    #raise ActiveRecord::IrreversibleMigration
  end
end
