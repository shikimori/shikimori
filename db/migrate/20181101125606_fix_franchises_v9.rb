class FixFranchisesV9 < ActiveRecord::Migration[5.2]
  def change
    Anime.where(franchise: 'hanamonogatari').update_all franchise: 'bakemonogatari'
    Achievement.where(neko_id: 'hanamonogatari').update_all neko_id: 'bakemonogatari'

    Anime.where(franchise: 'aria_the_ova').update_all franchise: 'aria_the_origination'
    Achievement.where(neko_id: 'aria_the_ova').update_all neko_id: 'aria_the_origination'

    Anime.where(franchise: 'yes_precure').update_all franchise: 'pretty_cure'
    Achievement.where(neko_id: 'yes_precure').update_all neko_id: 'pretty_cure'

    Anime.where(franchise: 'yamato').update_all franchise: 'uchuu_senkan_yamato'
    Achievement.where(neko_id: 'yamato').update_all neko_id: 'uchuu_senkan_yamato'

    Anime.where(franchise: 'nen_joou').update_all franchise: 'ginga_tetsudou'
    Achievement.where(neko_id: 'nen_joou').update_all neko_id: 'ginga_tetsudou'
  end
end
