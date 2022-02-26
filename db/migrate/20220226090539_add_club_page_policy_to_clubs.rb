class AddClubPagePolicyToClubs < ActiveRecord::Migration[5.2]
  def change
    add_column :clubs, :page_policy, :string,
      null: false,
      default: :admins
    change_column_default :clubs, :page_policy, from: :admins, to: nil
  end
end
