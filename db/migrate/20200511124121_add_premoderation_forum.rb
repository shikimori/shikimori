class AddPremoderationForum < ActiveRecord::Migration[5.2]
  def change
    Forum.create! id: 22,
      name_ru: 'Премодерация',
      name_en: 'Premoderation',
      permalink: 'premoderation',
      position: 999
  end

  def down
    Forum.find_by(id: 22)&.destroy
  end
end
