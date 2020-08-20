class DowncaseVideoKind < ActiveRecord::Migration[5.2]
  def up
    Video.where(kind: 'PV').update_all kind: 'pv'
    Video.where(kind: 'OP').update_all kind: 'op'
    Video.where(kind: 'ED').update_all kind: 'ed'
  end

  def down
    Video.where(kind: 'pv').update_all kind: 'PV'
    Video.where(kind: 'op').update_all kind: 'OP'
    Video.where(kind: 'ed').update_all kind: 'ED'
  end
end
