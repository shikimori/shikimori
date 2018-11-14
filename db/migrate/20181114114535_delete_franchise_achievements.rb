class DeleteFranchiseAchievements < ActiveRecord::Migration[5.2]
  def change
    Achievement
      .where(
        neko_id: %w[
          sonic
          tiger_mask
          getter_robo
          ojamajo_doremi
          kinnikuman
          super_robot_taisen_og
          zoids
          rean_no_tsubasa
          choujuu_kishin_dancougar
          ultraman
          dragon_quest
          super_doll_licca_chan
          mahou_no_princess_minky_momo
          juusenki_l_gaim
          obake_no_q_tarou
          ginga_senpuu_braiger
          pro_golfer_saru
          touch
          mahoujin_guruguru
          grendizer_giga
        ]
      )
      .delete_all
  end
end
