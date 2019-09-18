class FillLicensorInAnimes < ActiveRecord::Migration[5.2]
  def change
    fill [33970,35851,10259,37207], 'Capella Film'
    fill [34541,34944], 'ВГТРК'
    fill [32281,36936], 'Экспонента'
    fill [199,572,164,431,37682], 'Пионер'
    fill [28805], 'Cinema Prestige'
    fill [23273,28069,28999,31553], 'Синема Галэкси'
    fill [
      36144,35078,33354,35320,35073,33478,36027,35838,35712,36094,1546,157,34279,35997,36511,30484,
      16498,25777,35760,37597,37450,36474,35540,37349,31646,37675,37140,36726,36023,36475,25537,
      37141,35840,37979,37451,36633,37140,37999,37779
    ], 'Wakanim'
    fill [38691], 'Crunchyroll'
  end

private

  def fill ids, licensor
    Anime.where(id: ids).update_all licensor: licensor, updated_at: Time.zone.now
  end
end
