class AddUniqFriendsIndex < ActiveRecord::Migration
  def change
    while doubled_links.any?
      doubled_links.each(&:destroy)
    end
    add_index :friend_links, [:src_id, :dst_id], unique: true
  end

private

  def doubled_links
    FriendLink
      .group('src_id, dst_id')
      .having('count(*) > 1')
      .select('max(id) as id')
      .to_a
  end
end
