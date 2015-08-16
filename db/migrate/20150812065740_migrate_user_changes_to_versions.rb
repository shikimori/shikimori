class MigrateUserChangesToVersions < ActiveRecord::Migration
  def up
    #UserChange.
      #where(column: %w{description tags russian torrents_name screenshots video}).
      #each do |user_change|
        #next if user_change.prior.blank? && user_change.value.blank?

        #version = Version.create(
          #user_id: user_change.user_id,
          #state: user_change.status.downcase,
          #item_id: user_change.item_id,
          #item_type: user_change.model,
          #item_diff: item_diff(user_change),
          #moderator_id: user_change.approver_id,
          #reason: user_change.reason,
          #created_at: user_change.created_at,
          #type: pick_type(user_change)
        #)
      #end;
  end

  def down
    raise ActiveRecord::IrreversibleMigration unless Rails.env.development?
  end

private

  def pick_type user_change
    if user_change.column == 'description'
      Versions::DescriptionVersion.name
    elsif user_change.column == 'screenshots'
      Versions::ScreenshotsVersion.name
    elsif user_change.column == 'video'
      Versions::VideoVersion.name
    else
      nil
    end
  end

  def item_diff user_change
    if user_change.column != 'screenshots' && user_change.column != 'video'
      {
        user_change.column => [
          user_change.prior,
          user_change.value,
        ]
      }
    elsif user_change.action == 'screenshots_upload'
      {
        action: Versions::ScreenshotsVersion::ACTIONS[:upload],
        screenshots: user_change.value.split(',').map(&:to_i)
      }
    elsif user_change.action == 'screenshots_deletion'
      {
        action: Versions::ScreenshotsVersion::ACTIONS[:delete],
        screenshots: user_change.value.split(',').map(&:to_i)
      }
    elsif user_change.action == 'screenshots_position'
      {
        action: Versions::ScreenshotsVersion::ACTIONS[:reposition],
        screenshots: [
          user_change.prior.split(',').map(&:to_i),
          user_change.value.split(',').map(&:to_i)
        ]
      }
    elsif user_change.action == 'video_upload'
      {
        action: Versions::VideoVersion::ACTIONS[:upload],
        videos: user_change.value.split(',').map(&:to_i)
      }
    elsif user_change.action == 'video_deletion'
      {
        action: Versions::VideoVersion::ACTIONS[:delete],
        videos: user_change.value.split(',').map(&:to_i)
      }
    else
        raise ArgumentError
    end
  end
end
