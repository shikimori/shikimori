class ListImports::ParseFile
  method_object :file

  GZIP = 'gzip compressed data'

  class BrokenFileError < RuntimeError; end

  def call
    if xml?
      ListImports::ParseXml.call content
    elsif json?
      ListImports::ParseJson.call content
    else
      raise BrokenFileError
    end
  end

private

  def content
    @content ||= read_file.fix_encoding('utf-u', true)
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
    content.starts_with? '<?xml'
  end

  def json?
    content.starts_with? '['
  end
end
