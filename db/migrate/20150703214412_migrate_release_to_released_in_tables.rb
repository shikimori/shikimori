# migration in production console after deploy:
# Message.where(kind: 'release').pluck(:id).each_slice(5000).each_with_index {|batch, index| Message.where(id: batch).update_all kind: 'released'; puts index };
class MigrateReleaseToReleasedInTables < ActiveRecord::Migration
  def up
    Entry.where(action: 'release').update_all action: 'released'
    Message.where(kind: 'release').where('created_at > ?', 1.week.ago).order(id: :desc).update_all kind: 'released'

    if Rails.env.development?
      batches = Message.where(kind: 'release').pluck(:id).each_slice(5000);
      puts "preparing #{batches.size} batches to migrate..."
      batches.each_with_index {|batch, index| Message.where(id: batch).update_all kind: 'released'; puts index };
    end
  end

  def down
    Entry.where(action: 'released').update_all action: 'release'
    Message.where(kind: 'released').where('created_at > ?', 1.week.ago).order(id: :desc).update_all kind: 'release'
  end
end
