class AddCommentsPolicyToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :comment_policy, :string,
      null: false,
      default: 'users'
  end
end
