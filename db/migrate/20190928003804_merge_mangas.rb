class MergeMangas < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.env.production?

    DbEntry::MergeIntoOther.call entry: Manga.find(120772), other: Manga.find(121082)
    DbEntry::MergeIntoOther.call entry: Manga.find(120886), other: Manga.find(121079)
    DbEntry::MergeIntoOther.call entry: Manga.find(120805), other: Manga.find(121083)
    DbEntry::MergeIntoOther.call entry: Manga.find(32033), other: Manga.find(47953)
  end
end
