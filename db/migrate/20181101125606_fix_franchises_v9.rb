class FixFranchisesV9 < ActiveRecord::Migration[5.2]
  def change
    Anime.where(id: [7568, 4896, 36836, 31373, 36835, 32699]).update_all franchise: nil
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
      'chaos_head' => 'science_adventure',
      'fate_zero' => 'nasuverse',
      'vivid_strike' => 'mahou_shoujo_lyrical_nanoha',
      'umineko_no_naku_koro_ni' => 'when_they_cry'
    }.each do |old_name, new_name|
      Anime.where(franchise: old_name).update_all franchise: new_name
      Achievement.where(neko_id: old_name).update_all neko_id: new_name
    end
    Animes::UpdateFranchises.new.call [Anime]
  end
end
