class RelatedAnimesToNewSchema < ActiveRecord::Migration
  def self.up
    rename_column :related_animes, :anime_id, :source_id
    rename_column :related_animes, :related_id, :anime_id
    add_column :related_animes, :manga_id, :integer

    ActiveRecord::Base.connection.execute("update related_animes set manga_id=anime_id,anime_id=null where relation='Adaptation'")
  end

  def self.down
    ActiveRecord::Base.connection.execute("update related_animes set anime_id=manga_id,manga_id=null where relation='Adaptation'")

    rename_column :related_animes, :anime_id, :related_id
    rename_column :related_animes, :source_id, :anime_id
    remove_column :related_animes, :manga_id
  end
end
