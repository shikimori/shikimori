class AddNewForums < ActiveRecord::Migration
  def up
    Section.find_or_create_by(
      id: 16,
      name: 'Игры',
      permalink: 'games',
      position: '16',
      description: '',
      meta_title: '',
      meta_keywords: '',
      meta_description: '',
      is_visible: true
    )
    Section.find_or_create_by(
      id: 17,
      name: 'Визуальные новеллы',
      permalink: 'vn',
      position: '17',
      description: '',
      meta_title: '',
      meta_keywords: '',
      meta_description: '',
      is_visible: true
    )
  end

  def down
    Section.find(16).destroy
    Section.find(17).destroy
  end
end
