class FixFranchisesV9 < ActiveRecord::Migration[5.2]
  def change
    Anime.where(franchise: 'hanamonogatari').update_all franchise: 'bakemonogatari'
    Achievement.where(neko_id: 'hanamonogatari').update_all neko_id: 'bakemonogatari'

    Anime.where(franchise: 'aria_the_ova').update_all franchise: 'aria_the_origination'
    Achievement.where(neko_id: 'aria_the_ova').update_all neko_id: 'aria_the_origination'

    Anime.where(franchise: 'yes_precure').update_all franchise: 'pretty_cure'
    Achievement.where(neko_id: 'yes_precure').update_all neko_id: 'pretty_cure'
  end
end
