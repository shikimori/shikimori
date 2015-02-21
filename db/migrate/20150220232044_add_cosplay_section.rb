class AddCosplaySection < ActiveRecord::Migration
  def change
    Section.create!(
      id: Section::COSPLAY_ID,
      position: Section::COSPLAY_ID,
      is_visible: false,
      name: 'Косплей',
      description: 'Косплей персонажей аниме и манги',
      permalink: 'cosplay',
      meta_title: "Косплей персонажей аниме и манги",
      meta_keywords: "Косплей ",
      meta_description: "Косплей персонажей аниме и манги."
    )
  end
end
