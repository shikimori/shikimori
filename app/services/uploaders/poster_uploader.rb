require 'image_processing/vips'

class Uploaders::PosterUploader < Shrine
  include ImageProcessing::MiniMagick

  # https://shrinerb.com/docs/plugins/activerecord
  plugin :pretty_location
  plugin :derivatives, create_on_promote: true
  plugin :determine_mime_type
  plugin :validation_helpers
  plugin :remove_invalid
  plugin :infer_extension, force: true
  # plugin :metadata_attributes
  plugin :store_dimensions, analyzer: :mini_magick
  plugin :data_uri

  Attacher.derivatives do |original|
    magick = ImageProcessing::Vips.source(original)

    # large = magick.resize_to_limit(900, 1400)
    main_2x = magick.resize_to_limit(450, 700)
    main = magick.resize_to_limit(225, 350)

    {
      main_2x: medium.convert!('webp'),
      main_alt_2x: medium.call!,
      main: small.convert!('webp'),
      main_alt: small.call!
    }
  end

  Attacher.validate do
    validate_max_size(
      15.megabytes,
      message: 'is too large (max is 15 MB)'
    )
    validate_mime_type_inclusion(
      %w[image/jpg image/jpeg image/png image/webp],
      message: 'must be JPEG, PNG or WEBP'
    )
  end

  def generate_location io, record: nil, **context # rubocop:disable PerceivedComplexity, CyclomaticComplexity, MethodLength
    pretty_location io,
      **context,
      record: record,
      identifier: (
        if record.anime_id
          'animes'
        elsif record.manga_id
          'mangas'
        elsif record.character_id
          'characters'
        elsif record.person_id
          'people'
        end
      ),
      name: record.anime_id || record.manga_id || record.character_id || record.person_id ||
        context[:name]
  end
end
