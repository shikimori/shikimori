class UpdateNameEnInForums < ActiveRecord::Migration
  def change
    unless Rails.env.test?
      Forum.find(1).update! name_en: 'Anime and manga'
      Forum.find(4).update! name_en: 'Site'
      Forum.find(8).update! name_en: 'Off-Topic'
      Forum.find(10).update! name_en: 'Clubs'
      Forum.find(12).update! name_en: 'Reviews'
      Forum.find(13).update! name_en: 'Contests'
      Forum.find(15).update! name_en: 'Cosplay'
      Forum.find(16).update! name_en: 'Games'
      Forum.find(17).update! name_en: 'Visual novels'
    end
  end
end
