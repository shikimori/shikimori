class ChangeUsersAboutDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :about, from: nil, to: ''
    User.where(about: nil).update_all about: ''
  end
end
