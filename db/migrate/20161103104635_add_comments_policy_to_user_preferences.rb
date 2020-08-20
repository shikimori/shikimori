class AddCommentsPolicyToUserPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :user_preferences, :comment_policy, :string,
      null: false,
      default: 'users'
  end
end
