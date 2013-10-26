class MigrateAnimeCommentsToAnimeComment < ActiveRecord::Migration
  def self.up
    Comment.record_timestamps = false
    AnimeComment.record_timestamps = false

    Comment.where(:commentable_type => 'Anime').includes(:commentable).all.group_by {|v| v.commentable_id }.each do |anime_id, comments|
      anime_comment = AnimeComment.create(:linked => comments.first.commentable,
                                          :created_at => comments.first.created_at,
                                          :updated_at => comments.last.updated_at,
                                          :comment_threads_count => comments.size)
      comments.each do |comment|
        comment.commentable_type = Entry.name
        comment.commentable_id = anime_comment.id
        comment.save
      end
    end
  end

  def self.down
  end
end
