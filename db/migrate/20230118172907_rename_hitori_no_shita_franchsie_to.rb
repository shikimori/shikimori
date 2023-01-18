class RenameHitoriNoShitaFranchsieTo < ActiveRecord::Migration[6.1]
  def up
    Achievement.where(neko_id: 'hitori_no_shita').update_all neko_id: 'yi_ren_zhi_xia'
    Anime.where(franchise: 'hitori_no_shita').update_all franchise: 'yi_ren_zhi_xia'
  end

  def down
    Achievement.where(neko_id: 'yi_ren_zhi_xia').update_all neko_id: 'hitori_no_shita'
    Anime.where(franchise: 'yi_ren_zhi_xia').update_all franchise: 'hitori_no_shita'
  end
end
