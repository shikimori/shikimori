class UserListParser
  def initialize klass
    @klass = klass
  end

  def parse params
    return case params[:list_type].to_sym
      when :mal
        UserListParsers::JsonListParser.new(@klass).parse params[:data]

      when :anime_planet
        UserListParsers::AnimePlanetListParser.new(@klass).parse params[:login]

      when :xml
        UserListParsers::XmlListParser.new(@klass).parse extract_xml(params[:file])

      else
        raise UnsupportedListType, params[:list_type]
    end
  end

private
  def extract_xml file
    if file.respond_to?(:read)
      if original_filename.respond_to?(:original_filename) && file.original_filename =~ /\.gz$/
        Zlib::GzipReader.open(file.tempfile).read
      else
        file.read
      end
    else
      file
    end
  end
end
