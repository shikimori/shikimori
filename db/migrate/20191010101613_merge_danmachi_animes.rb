class MergeDanmachiAnimes < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.env.production?

    DbEntry::MergeIntoOther.call entry: Anime.find(40068), other: Anime.find(40064)
  end
end
