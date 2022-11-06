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

  Attacher.derivatives do |original|
    magick = ImageProcessing::Vips.source(original)

    large = magick.resize_to_limit(900, 1400)
    medium = magick.resize_to_limit(450, 700)
    small = magick.resize_to_limit(225, 350)

    {
      large: large.convert!('webp'),
      large_legacy: large.call!,
      medium: medium.convert!('webp'),
      medium_legacy: medium.call!,
      small: small.convert!('webp'),
      small_legacy: small.call!
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

  # plugin :processing
  # plugin :versions
  # plugin :delete_raw
  # plugin :determine_mime_type
  # plugin :presign_endpoint
  # plugin :delete_promoted
  #
  # plugin :default_url_options, store: ->(io, **_options) do
  #   {
  #     response_content_disposition: ContentDisposition.format(
  #       disposition: 'inline',
  #       filename: io.original_filename
  #     )
  #   }
  # end
  #
  # process(:store) do |io, _context|
  #   original = io.download
  #
  #   pipeline = ImageProcessing::MiniMagick
  #     .source(original)
  #     .sampling_factor('4:2:0')
  #     .strip
  #     .quality(85)
  #     .interlace('JPEG')
  #
  #   size_256 = pipeline.resize_to_fill!(256, 364)
  #   size_444 = pipeline.resize_to_fill!(444, 508)
  #   size_1200 = pipeline.resize_to_limit(1200, nil).convert!('jpg')
  #
  #   original.close
  #
  #   {
  #     original: size_1200,
  #     x256: size_256,
  #     x444: size_444
  #   }
  # end
end
