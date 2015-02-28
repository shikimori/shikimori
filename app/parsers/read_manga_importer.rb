class ReadMangaImporter
  # префикс для id в базе
  Prefix = "rm_"

  def initialize
    @parser = self.class.name.sub('Importer', 'Parser').constantize.new
  end

  def self.import(options)
    self.new.import options
  end

  # импорт по страницам или по id в базу
  def import(options = {})
    options[:pages] = 0..(@parser.fetch_pages_num - 1) unless options[:pages] || options[:id]

    print "preparing mangas for import...\n" if Rails.env != 'test'
    db_data = prepare_db_data
    print "fetched #{db_data.size} entries\n" if Rails.env != 'test'

    ids_with_description = prepare_user_changed_ids

    print "preparing import entries for import...\n" if Rails.env != 'test'
    import_data = prepare_import_data(
        options[:ids] ?
          Array(options[:ids]).map {|id| @parser.fetch_entry id } :
          @parser.fetch_pages(options[:pages])
      )
    print "fetched #{import_data.size} entries\n" if Rails.env != 'test'

    matched = merge_data(db_data, import_data, ids_with_description)
    print "%d matches found\n" % matched if Rails.env != 'test'
  end

  # выборка из базы того, куда импортироватьс
  def prepare_db_data
    all_mangas = Manga.select([:id, :name, :english, :japanese, :synonyms, :russian, :description, :description_html, :read_manga_scores, :read_manga_id, :source, :kind])
                      .order(:kind)
                      .all

    all_mangas.map do |m|
      {
        names: [SiteParserWithCache.fix_name(m.name)] +
                (m.english ? m.english.map {|v| SiteParserWithCache.fix_name(v) } : []) +
                (m.synonyms ? m.synonyms.map {|v| SiteParserWithCache.fix_name(v) } : []) +
                (m.japanese ? m.japanese.map {|v| SiteParserWithCache.fix_name(v) } : []),
        entry: m,
        id: m[:id]
      }
    end
  end

  # выборка из базы id элементов с пользовательскими правками
  def prepare_user_changed_ids
    UserChange
      .where(model: 'manga', status: [UserChangeStatus::Accepted, UserChangeStatus::Taken], column: 'description')
      .select(:item_id)
      .map(&:item_id)
      .uniq
  end

  # подготовка того, что импортировать
  def prepare_import_data(data)
    data.map do |entry|
      entry[:names] = entry[:names].map {|v| SiteParserWithCache.fix_name(v) }
      entry[:names] << SiteParserWithCache.fix_name(entry[:russian])
      entry[:names].uniq!
      entry
    end
  end

  # импорт данных в базу
  def merge_data db_data, import_data, ids_with_description
    matched = 0

    import_data.each do |import_entry|
      db_data.each do |db_entry|
        if entries_matched?(import_entry, db_entry)
          unless import_entry[:description].blank? || ids_with_description.include?(db_entry[:id]) || import_entry[:description].length < 60
            db_entry[:entry].description = import_entry[:description]
            db_entry[:entry].source = import_entry[:source]
          end
          if import_entry[:russian].present? && db_entry[:entry].russian.blank? && db_entry[:entry].name != import_entry[:russian] && import_entry[:russian] =~ /[А-я]/
            db_entry[:entry].russian = import_entry[:russian]
          end
          db_entry[:entry].read_manga_id = self.class::Prefix+import_entry[:id]
          db_entry[:entry].read_manga_scores = import_entry[:score] if db_entry[:entry].read_manga_scores.to_s != import_entry[:score].to_s
          db_entry[:entry].save(validate: false) if db_entry[:entry].changes.any?

          matched += 1
          break
        end
      end
    end

    matched
  end

  # одинаковые ли элементы?
  def entries_matched? import_entry, db_entry
    link = ReadMangaImportData::CustomLinks[import_entry[:id]]

    !(self.class::Prefix == AdultMangaImporter::Prefix && import_entry[:kind] == 'One Shot' && db_entry[:entry].manga?) && # адалт ваншоты с мангами не матчим
      (!link && (import_entry[:names] & db_entry[:names]).any?) || (link && link == db_entry[:id])
  end
end
