class UserListParser
  def initialize klass
    @klass = klass
  end

  def parse params
    return case params[:list_type].to_sym
      when :mal
        UserListParsers::MalListParser.new(@klass).parse params[:data]

      when :anime_planet
        UserListParsers::AnimePlanetListParser.new(@klass).parse params[:login]

      when :xml

      else
        raise UnsupportedListType, params[:list_type]
    end

    return


    if params[:list_type].to_sym == :xml
      raw_xml = if params[:file].kind_of? ActionDispatch::Http::UploadedFile
        if params[:file].original_filename =~ /\.gz$/
          Zlib::GzipReader.open(params[:file].tempfile).read
        else
          params[:file].read
        end
      else
        Rails.env.test? ? params[:file] : params[:file].read
      end

      prepared_list = Hash.from_xml(raw_xml.fix_encoding)['myanimelist'][params[:klass]]
      prepared_list = [prepared_list] if prepared_list.kind_of?(Hash)
      prepared_list.map! do |v|
        {
          id: (v['series_animedb_id'] || v['series_mangadb_id'] || v['manga_mangadb_id'] || v['anime_animedb_id']).to_i,
          episodes: v['my_watched_episodes'] || 0,
          volumes: v['my_read_volumes'] || 0,
          chapters: v['my_read_chapters'] || 0,
          status: v['my_status'] =~ /^\d+$/ ? UserRateStatus.get(v['my_status'].to_i) : v['my_status'].sub('Plan to Read', 'Plan to Watch').sub('Reading', 'Watching'),
          score: v['my_score'] || 0
        }
      end
      @added, @updated, @not_imported = importer.import(prepared_list, rewrite)
      params[:list_type] = 'mal'

    else
      raise Forbidden
    end

  end
end
