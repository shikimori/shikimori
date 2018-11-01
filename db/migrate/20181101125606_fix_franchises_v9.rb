class FixFranchisesV9 < ActiveRecord::Migration[5.2]
  def change
    Anime.where(franchise: 'hanamonogatari').update_all franchise: 'bakemonogatari'
    Achievement.where(neko_id: 'hanamonogatari').update_all neko_id: 'bakemonogatari'

    Anime.where(franchise: 'aria_the_ova').update_all franchise: 'aria_the_origination'
    Achievement.where(neko_id: 'aria_the_ova').update_all neko_id: 'aria_the_origination'
  end
end
