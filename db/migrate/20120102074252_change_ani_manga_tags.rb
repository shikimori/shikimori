class ChangeAniMangaTags < ActiveRecord::Migration
  def self.up
    tags = Set.new(DanbooruTag.where(:kind => DanbooruTag::Copyright).all.map {|v| v.name })
    [Anime, Manga].each do |klass|
      ActiveRecord::Base.connection.execute("update #{klass.name.tableize} set tags = null")
      entries = klass.where(:tags => nil).all

      entries.each do |v|
        tag = DanbooruTag.match([v.name] + (v.english || []) + (v.synonyms || []), tags)
        v.update_attribute(:tags, tag) if tag
      end
    end
  end
end
