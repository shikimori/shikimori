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

    Anime.where(franchise: 'magical_star_kanon').update_all franchise: 'kami_nomi_zo_shiru_sekai'

    Anime.where(franchise: 'tales_of_gekijou').update_all franchise: 'tales_of'
    Achievement.where(neko_id: 'tales_of_gekijou').update_all neko_id: 'tales_of'

    Anime.where(franchise: 'moon_pride').update_all franchise: 'sailor_moon'
    Achievement.where(neko_id: 'tales_of_gekijou').update_all neko_id: 'tales_of'
  end
end
