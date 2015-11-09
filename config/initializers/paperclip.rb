Paperclip.interpolates :user_id do |attachment, style|
  attachment.instance.user_id
end

Paperclip.interpolates :access_token  do |attachment, style|
  attachment.instance.access_token
end

# manga online
Paperclip.interpolates :manga_id_mod do |attachment, style|
  attachment.instance.manga_id_mod
end

Paperclip.interpolates :manga_id do |attachment, style|
  attachment.instance.manga_id
end

Paperclip.interpolates :chapter_name do |attachment, style|
  attachment.instance.chapter_name
end

Paperclip.interpolates :number do |attachment, style|
  attachment.instance.number
end
# ----

# отключаем проверку на spoofing, она работает как-то странно
module Paperclip::HasAttachedFile::WithoutSpoofingCheck
  def add_required_validations
  end
end
Paperclip::HasAttachedFile.send :prepend, Paperclip::HasAttachedFile::WithoutSpoofingCheck

# c 46 строки хак от эксплойта, вешающего сервер из-за загружаемой картинки
# размером 225000x225000. нужно обязательно отключить use_exif_orientation
Paperclip.options[:use_exif_orientation] = false
module Paperclip
  class GeometryDetector
    def initialize(file)
      @file = file
      raise_if_blank_file
    end

    def make
      geometry = GeometryParser.new(geometry_string.strip).make

      raise(Errors::NotIdentifiedByImageMagickError.new) unless geometry

      if geometry.width.to_i > 10000 || geometry.height.to_i > 10000
        raise 'bad image'
      else
        geometry
      end
    end

    private

    def geometry_string
      begin
        orientation = Paperclip.options[:use_exif_orientation] ?
          "%[exif:orientation]" : "1"
        Paperclip.run(
          "identify",
          "-format '%wx%h,#{orientation}' :file", {
            :file => "#{path}[0]"
          }, {
            :swallow_stderr => true
          }
        )
      rescue Cocaine::ExitStatusError
        ""
      rescue Cocaine::CommandNotFoundError => e
        raise_because_imagemagick_missing
      end
    end

    def path
      @file.respond_to?(:path) ? @file.path : @file
    end

    def raise_if_blank_file
      if path.blank?
        raise Errors::NotIdentifiedByImageMagickError.new("Cannot find the geometry of a file with a blank name")
      end
    end

    def raise_because_imagemagick_missing
      raise Errors::CommandNotFoundError.new("Could not run the `identify` command. Please install ImageMagick.")
    end
  end
end
