class RemoveDouluoDaluFranchise < ActiveRecord::Migration[6.1]
  def change
    Achievement.where(neko_id: 'douluo_dalu').delete_all
  end
end
