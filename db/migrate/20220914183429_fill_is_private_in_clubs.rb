class FillIsPrivateInClubs < ActiveRecord::Migration[6.1]
  def up
    Club
      .where(is_censored: true)
      .where.not(join_policy: Types::Club::JoinPolicy[:free])
      .where.not(comment_policy: Types::Club::CommentPolicy[:free])
      .update_all is_private: true
  end
end
