class FixFranchisesV9 < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: 'hanamonogatari').update_all neko_id: 'bakemonogatari'
  end
end
