class SetGeneratedToComments < ActiveRecord::Migration
  def up
    AniMangaComment.update_all generated: true
    CharacterComment.update_all generated: true
    GroupComment.update_all generated: true
  end
end
