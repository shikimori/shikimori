class AddHiddenForum < ActiveRecord::Migration[5.2]
  def up
    Forum
      .find_or_initialize_by(id: Forum::HIDDEN_ID)
      .update!(
        name_ru: 'Скрытый',
        name_en: 'Hidden',
        permalink: 'hidden',
        position: 99
      )
  end

  def down
    Forum.find_by(id: Forum::HIDDEN_ID)&.destroy!
  end
end
