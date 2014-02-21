class UpdateSections < ActiveRecord::Migration
  def change
    Section.update_all is_visible: true
    Section.where(permalink: ['c', 'g', 'reviews', 'v']).update_all is_visible: false
    Section.find(13).update position: 11
  end
end
