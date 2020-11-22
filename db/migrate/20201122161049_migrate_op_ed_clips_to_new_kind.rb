class MigrateOpEdClipsToNewKind < ActiveRecord::Migration[5.2]
  def change
    Video.where(kind: %i[op_clip ed_clip]).update_all kind: 'op_ed_clip'
  end
end
