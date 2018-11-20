class RemoveSmallFranchiseAchievements < ActiveRecord::Migration[5.2]
  def change
    Achievement
      .where(
        neko_id: %i[
          tengen_toppa_gurren_lagann
          ajin
          appleseed
          zettai_karen_children
          sket_dance
          hikaru_no_go
          touken_ranbu
          candy_candy
        ]
      ).delete_all
  end
end
