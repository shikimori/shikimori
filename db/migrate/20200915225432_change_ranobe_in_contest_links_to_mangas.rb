class ChangeRanobeInContestLinksToMangas < ActiveRecord::Migration[5.2]
  def change
    ContestLink
      .where(linked_type: Ranobe.name)
      .update_all(linked_type: Manga.name)

    ContestWinner
      .where(item_type: Ranobe.name)
      .update_all(item_type: Manga.name)
  end
end
