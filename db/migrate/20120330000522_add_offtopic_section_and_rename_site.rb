
class AddOfftopicSectionAndRenameSite < ActiveRecord::Migration
  def self.up
    Section.find(4).update_attributes(name: 'Сайт')
    Section.create(forum_id: 2, permalink: 'offtopic', position: 2, name: 'Оффтопик', description: 'Обсуждение на свободные темы. Всё, что не подходит для других разделов.')
  end

  def self.down
    Section.find(4).update_attributes(name: 'Общий')
  end
end
