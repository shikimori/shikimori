class MigrateSiteNewsToBlogEntries < ActiveRecord::Migration
  def self.up
    #SiteNews.record_timestamps = false
    #SiteNews.all.each do |v|
      #v.update_attribute(:featured, true)
      #v.update_attribute(:type, 'BlogPost')
    #end
    #SiteNews.record_timestamps = true
  end

  def self.down
    #BlogPost.record_timestamps = false
    #BlogPost.all.each do |v|
      #v.update_attribute(:featured, false)
      #v.update_attribute(:type, 'SiteNews')
    #end
    #BlogPost.record_timestamps = true
  end
end
