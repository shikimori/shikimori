class AddNewForums < ActiveRecord::Migration
  def up
    Forum.create(
      id: 16,
      name: 'Игры',
      permalink: 'games',
      position: '3',
      description: '',
      meta_title: '',
      meta_keywords: '',
      meta_description: '',
      is_visible: true
    )
    Forum.create(
      id: 17,
      name: 'Визуальные новеллы',
      permalink: 'vn',
      position: '2',
      description: '',
      meta_title: '',
      meta_keywords: '',
      meta_description: '',
      is_visible: true
    )
  end

  def down
    Forum.find(16).destroy
    Forum.find(17).destroy
  end
end
