class FetchPausedAndDiscontinuedMangas < ActiveRecord::Migration[5.2]
  IDS = [
    3631,
    45597,
    25541,
    3068,
    96291,
    28,
    15469,
    112740,
    3083,
    26690,
    656,
    27,
    116035,
    96549,
    118771,
    118649,
    96550,
    669,
    109785,
    122005,
    117523,
    112609,
    15536,
  ]

  def change
    Manga.where(id: IDS).each do |manga|
      manga.update! desynced: manga.desynced.reject { |v| v == 'status' }
      MalParsers::FetchEntry.perform_in 1.minute, manga.id, 'manga'
    end
  end
end
