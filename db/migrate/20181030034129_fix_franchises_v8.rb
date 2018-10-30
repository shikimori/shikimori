class FixFranchisesV8 < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: 'koneko_no_chii').update_all neko_id: 'koneko_no_chi'
  end
end
