class RemoveDefaultFromLayoutInClubPages < ActiveRecord::Migration[5.2]
  def up
    change_column_default :club_pages, :layout, default: nil
  end

  def up
    change_column_default :club_pages, :layout,
      default: Types::ClubPage::Layout[:content]
  end
end
