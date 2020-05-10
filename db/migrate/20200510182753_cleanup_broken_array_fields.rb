class CleanupBrokenArrayFields < ActiveRecord::Migration[5.2]
  FIELDS = {
    Studio => %i[desynced],
    Publisher => %i[desynced],
    Character => %i[desynced],
    Person => %i[desynced],
    Anime => %i[desynced synonyms coub_tags options fansubbers fandubbers],
    Manga => %i[desynced synonyms]
  }

  def change
    FIELDS.each do |klass, fields|
      ap klass

      klass.find_each do |db_entry|
        fields.each do |field|
          db_entry.send(:"#{field}=", db_entry.send(field).select(&:present?))
        end

        if db_entry.changed?
          ap id: db_entry.id, class: db_entry.class.name
          ap db_entry.changes
        end

        db_entry.save!
      end
    end
  end
end
