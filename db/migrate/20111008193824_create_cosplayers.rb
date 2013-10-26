class CreateCosplayers < ActiveRecord::Migration
  def self.up
    create_table :cosplayers do |t|
      t.string :name
      t.string :website
      t.string :image_url

      t.timestamps
    end
    add_index :cosplayers, :name, :unique => true

    create_table :cosplay_galleries do |t|
      t.string :cos_rain_id
      t.string :target
      t.date :date
      t.string :type
      t.text :description_cos_rain
      t.text :description

      t.timestamps
    end
    add_index :cosplay_galleries, :cos_rain_id, :unique => true

    create_table :cosplay_images do |t|
      t.integer :cosplay_gallery_id
      t.string :url
      t.timestamps
    end
    add_index :cosplay_images, :url

    create_table :cosplay_gallery_links do |t|
      t.integer :linked_id
      t.string :linked_type
      t.integer :cosplay_gallery_id

      t.timestamps
    end
    add_index :cosplay_gallery_links, [:linked_id, :linked_type, :cosplay_gallery_id], :unique => true, :name => 'index_cosplay_gallery_links_on_l_id_and_l_type_and_cg_id'
  end

  def self.down
    drop_table :cosplayers
    drop_table :cosplay_galleries
    drop_table :cosplay_images
    drop_table :cosplay_gallery_links
  end
end
