class FixFranchisesV10 < ActiveRecord::Migration[5.2]
  def change
    {
      'aria_the_origination' => 'aria',
      'nasuverse' => 'fate',
      'koro_sensei_q' => 'ansatsu_kyoushitsu',
      'amon' => 'devilman',
      'megalo_box' => 'ashita_no_joe',
      'dmatsu_san' => 'osomatsu_san',
      'aquarion_evol' => 'aquarion',
      'digimon_savers' => 'digimon',
      'saiyuuki_gaiden' => 'saiyuuki',
      'iron_man' => 'marvel',
      'ehon_yose' => 'gegege_no_kitarou',
      'mahouka_x_mameshiba' => 'mahouka_koukou_no_rettousei'
    }.each do |old_name, new_name|
      Anime.where(franchise: old_name).update_all franchise: new_name
      Achievement.where(neko_id: old_name).update_all neko_id: new_name
    end
    Animes::UpdateFranchises.new.call Anime.where(franchise: 'batman')
  end
end
