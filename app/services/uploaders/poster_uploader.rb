require 'image_processing/vips'

class Uploaders::PosterUploader < Shrine
  include ImageProcessing::MiniMagick

  MAIN_WIDTH = 225
  MAIN_HEIGHT = 350

  # preview ratio: 0.6812227074
  PREVIEW_WIDTH = 156
  PREVIEW_HEIGHT = 229

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
    magick = ImageProcessing::Vips.source original

    main_2x = magick.resize_to_limit MAIN_WIDTH * 2, MAIN_HEIGHT * 2
    main = magick.resize_to_limit MAIN_WIDTH, MAIN_HEIGHT

    magick_cropped = magick.crop(
      record.crop_data['left'],
      record.crop_data['top'],
      record.crop_data['width'],
      record.crop_data['height']
    )

    preview_2x = magick_cropped.resize_to_limit PREVIEW_WIDTH * 2, PREVIEW_HEIGHT * 2
    preview = magick_cropped.resize_to_limit PREVIEW_WIDTH, PREVIEW_HEIGHT

    {
      main_2x: main_2x.convert!('webp'),
      main: main.convert!('webp'),
      main_alt_2x: main_2x.call!,
      main_alt: main.call!,
      preview_2x: preview_2x.convert!('webp'),
      preview: preview.convert!('webp'),
      preview_alt_2x: preview_2x.call!,
      preview_alt: preview.call!
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
