# TODO: удалить после миграция UserChange на Version
class UserChangesQuery
  def initialize entry, field
    @entry = entry
    @field = field.to_s
  end

  def fetch
    UserChange
      .where(item_id: @entry.id, model: @entry.class.name, column: @field)
      .where(status: [UserChangeStatus::Pending, UserChangeStatus::Taken, UserChangeStatus::Accepted])
      .includes(:user)
      .includes(:approver)
      .order(created_at: :desc)
  end

  def authors with_taken = true
    fetch
      .where(status: with_taken ? [UserChangeStatus::Taken, UserChangeStatus::Accepted] : [UserChangeStatus::Accepted])
      .where(video_presence_filter)
      .map(&:user)
      .uniq
  end

private

  def video_presence_filter
    if @field.to_sym == :video
      {
        value: Video
          .where(anime_id: @entry.id)
          .where.not(state: :deleted)
          .pluck(:id)
          .map(&:to_s)
      }
    else
      '1=1'
    end
  end
end
