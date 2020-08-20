class FillJoinAndCommentPolicyToClubs < ActiveRecord::Migration[5.2]
  def up
    Club
      .where(join_policy: 1)
      .update_all join_policy_new: Types::Club::JoinPolicy[:free]
    Club
      .where(join_policy: 50)
      .update_all join_policy_new: Types::Club::JoinPolicy[:admin_invite]
    Club
      .where(join_policy: 100)
      .update_all join_policy_new: Types::Club::JoinPolicy[:owner_invite]

    Club
      .where(comment_policy: 1)
      .update_all comment_policy_new: Types::Club::CommentPolicy[:free]
    Club
      .where(comment_policy: 100)
      .update_all comment_policy_new: Types::Club::CommentPolicy[:members]
  end

  def down
    Club
      .where(join_policy_new: Types::Club::JoinPolicy[:free])
      .update_all join_policy: 1
    Club
      .where(join_policy_new: Types::Club::JoinPolicy[:admin_invite])
      .update_all join_policy: 50
    Club
      .where(join_policy_new: Types::Club::JoinPolicy[:owner_invite])
      .update_all join_policy: 100

    Club
      .where(comment_policy_new: Types::Club::CommentPolicy[:free])
      .update_all comment_policy: 1
    Club
      .where(comment_policy_new: Types::Club::CommentPolicy[:members])
      .update_all comment_policy: 100
  end
end
