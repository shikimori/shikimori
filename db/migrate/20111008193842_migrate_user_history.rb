class MigrateUserHistory < ActiveRecord::Migration
  def self.up
    UserHistory.where(:target_id.not_in => Anime.select(:id).all.map(&:id)).delete_all

    UserHistory.record_timestamps = false
    history = UserHistory.includes(:target).includes(:user).order(:id).all
    UserHistory.delete_all

    mapping = User.all.inject({}) do |sum,v|
      sum[v.id] = {
          UserHistoryAction::Rate => {},
          UserHistoryAction::Episodes => {},
        }
      sum
    end

    history.each do |entry|
      use_prior = entry.action == UserHistoryAction::Rate || entry.action == UserHistoryAction::Episodes

      UserHistory.add(entry.user, entry.target, entry.action, entry.value ? entry.value.to_i : entry.value, use_prior ? mapping[entry.user.id][entry.action][entry.target.id] : nil)
      UserHistory.last.update_attributes(:created_at => entry.created_at, :updated_at => entry.updated_at)

      mapping[entry.user.id][entry.action][entry.target.id] = entry.value.to_i if use_prior

    end
    UserHistory.record_timestamps = true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
