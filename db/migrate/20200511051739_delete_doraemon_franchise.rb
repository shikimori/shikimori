class DeleteDoraemonFranchise < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: 'doraemon').delete_all
  end
end
