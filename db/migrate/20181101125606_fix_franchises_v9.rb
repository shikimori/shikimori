class FixFranchisesV9 < ActiveRecord::Migration[5.2]
  def change
    {
      'hanamonogatari' => 'bakemonogatari',
      'aria_the_ova' => 'aria_the_origination',
      'yes_precure' => 'pretty_cure',
      'yamato' => 'uchuu_senkan_yamato',
      'nen_joou' => 'ginga_tetsudou',
      'magical_star_kanon' => 'kami_nomi_zo_shiru_sekai',
      'tales_of_gekijou' => 'tales_of',
      'moon_pride' => 'sailor_moon',
      'believe' => 'time_bokan',
      'snow_halation' => 'love_live',
      'force_live' => 'uta_no_prince_sama',
      'chaos_head' => 'science_adventure'
    }.each do |old_name, new_name|
      Anime.where(franchise: old_name).update_all franchise: new_name
      Achievement.where(neko_id: old_name).update_all neko_id: new_name
    end
    Animes::UpdateFranchises.new.call Anime.where(franchise: 'casshan')
  end
end
