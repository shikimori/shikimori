class AddMemberTypeToContests < ActiveRecord::Migration
  def change
    add_column :contests, :member_type, :string, default: :anime
  end
end
