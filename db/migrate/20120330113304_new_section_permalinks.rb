
class NewSectionPermalinks < ActiveRecord::Migration
  def self.up
    Section.find_by_permalink('anime').update_attributes(permalink: 'a', position: 1, description: 'Обсуждение аниме и всего, что с этим связано.')
    Section.find_by_permalink('manga').update_attributes(permalink: 'm', position: 2, description: 'Обсуждение манги и всего, что с ней связано.')
    Section.find_by_permalink('personazhi').update_attributes(permalink: 'c', position: 3, description: 'Обсуждение персонажей аниме и манги.')
    Section.find_by_permalink('site').update_attributes(permalink: 's', position: 4, description: 'Новости сайта, идеи, предложения и отзывы.')
    Section.find_by_permalink('offtopic').update_attributes(permalink: 'f', position: 5, description: 'Разговор на свободные темы.')
    Section.where(permalink: 'test').destroy_all
  end

  def self.down
    Section.find_by_permalink('a').update_attributes(permalink: 'anime')
    Section.find_by_permalink('m').update_attributes(permalink: 'manga')
    Section.find_by_permalink('s').update_attributes(permalink: 'site')
    Section.find_by_permalink('c').update_attributes(permalink: 'personazhi')
    Section.find_by_permalink('f').update_attributes(permalink: 'offtopic')
  end
end
