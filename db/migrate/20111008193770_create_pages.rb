class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :name
      t.text :content
      t.string :url

      t.timestamps
    end
    Page.new(:name => 'Гостевая', :url => 'guestbook', :content => '<p>Здесь вы можете оставить отзыв о сайте.</p>').save
    Page.new(:name => 'О сайте', :url => 'about', :content => '').save
    Page.new(:name => 'Пользовательское соглавшение', :url => 'user_agreement', :content => '').save
  end

  def self.down
    drop_table :pages
  end
end
