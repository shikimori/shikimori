class RemoveYuuriAndFujoshi < ActiveRecord::Migration[7.0]
  def change
    Achievement.where(neko_id: %i[fujoshi yuuri]).delete_all
  end
end
