class RemoveSmallFranchiseAchievementsV2 < ActiveRecord::Migration[5.2]
  def change
    Achievement
      .where(
        neko_id: %i[
          infinite_stratos
          mahouka_koukou_no_rettousei
          girls_panzer
          terra_formars
          guyver
        ]
      ).delete_all
  end
end
