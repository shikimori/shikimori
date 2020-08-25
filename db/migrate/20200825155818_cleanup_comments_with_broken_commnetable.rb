class CleanupCommentsWithBrokenCommnetable < ActiveRecord::Migration[5.2]
  def change
    Comment.where(commentable_type: 'CosplayGallery').destroy_all
  end
end
