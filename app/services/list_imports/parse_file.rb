class ListImports::ParseFile
  method_object :file

  GZIP = 'gzip compressed data'

  def call
    if xml?
      ListImports::ParseXml.call content
    else
      JSON.parse content, symbolize_names: true
    end
  end

private

  def content
    read_file.fix_encoding('utf-u', true)
  end

  def read_file
    if gzip?
      Zlib::GzipReader.new(
        @file,
        external_encoding: 'utf-8',
        internal_encoding: 'utf-8'
      ).read
    else
      @file.read
    end
  end

  def gzip?
    `file #{@file.path}`.include?(GZIP)
  end

  def xml?
    @file.path.match?(/\.xml(?:\.gz)?$/)
  end
end
