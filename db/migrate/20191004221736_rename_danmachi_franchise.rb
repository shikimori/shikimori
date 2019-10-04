class RenameDanmachiFranchise < ActiveRecord::Migration[5.2]
  def change
    Anime
      .where(franchise: 'dungeon_ni_deai_wo_motomeru_no_wa_machigatteiru_darou_ka')
      .update_all franchise: 'danmachi'
  end
end
