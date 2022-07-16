class MakeClubPageUserIdNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :club_pages, :user_id, false
  end
end
