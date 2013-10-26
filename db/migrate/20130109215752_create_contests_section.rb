class CreateContestsSection < ActiveRecord::Migration
  def self.up
    Section.find_or_create_by_id(Section::ContestsId, {
      name: 'Опросы',
      description: "Обсуждение опросов и турниров по аниме, манга и всего, что с этим связано",
      forum_id: 2
    })
    Section.find(Section::ContestsId).update_attributes({
      permalink: 'v',
      meta_title: 'Опросы',
      meta_keywords: 'аниме опросы турниры голосования форум',
      meta_description: 'Обсуждение опросов и турниров по аниме, манга и всего, что с этим связано'
    })
  end

  def self.down
  end
end
