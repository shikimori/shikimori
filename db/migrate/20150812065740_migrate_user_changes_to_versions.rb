class MigrateUserChangesToVersions < ActiveRecord::Migration
  def up
    UserChange
      .where(column: %w{description tags russian torrents_name})
      .each do |user_change|
        next if user_change.prior.blank? && user_change.value.blank?

        Version.create(
          user_id: user_change.user_id,
          state: user_change.status.downcase,
          item_id: user_change.item_id,
          item_type: user_change.model,
          item_diff: {
            user_change.column => [
              user_change.prior,
              user_change.value,
            ]
          },
          moderator_id: user_change.approver_id,
          reason: user_change.reason,
          created_at: user_change.created_at,
          type: pick_type(user_change)
        )
      end
  end

  def down
    raise ActiveRecord::IrreversibleMigration unless Rails.env.development?
  end

private

  def pick_type user_change
    if user_change.column == 'description'
      Versions::DescriptionVersion.name
    else
      nil
    end
  end
end
