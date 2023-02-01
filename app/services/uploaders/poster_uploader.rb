class Uploaders::PosterUploader < Shrine
  include ImageProcessing::MiniMagick

  MAIN_WIDTH = 225
  # MAIN_HEIGHT = 350

  PREVIEW_WIDTH = 160
  PREVIEW_ANIME_HEIGHT = (PREVIEW_WIDTH / (425.0 / 600.0)).ceil
  PREVIEW_CHARACTER_HEIGHT = (PREVIEW_WIDTH / (225.0 / 350.0)).ceil

  MINI_WIDTH = 48
  MINI_HEIGHT = 75

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
    # magick = ImageProcessing::Vips.source(original).saver(quality: 94)
    magick = ImageProcessing::MiniMagick.source(original).saver(quality: 94)

    main_2x = magick.resize_to_fit MAIN_WIDTH * 2, nil # MAIN_HEIGHT * 2
    main = magick.resize_to_fit MAIN_WIDTH, nil # MAIN_HEIGHT

    magick_cropped = record.crop_data.blank? ?
      magick :
      magick.crop(
        record.crop_data['left'],
        record.crop_data['top'],
        record.crop_data['width'],
        record.crop_data['height']
      )

    preview_height = record.anime_id || record.manga_id ?
      PREVIEW_ANIME_HEIGHT :
      PREVIEW_CHARACTER_HEIGHT

    preview_2x = magick_cropped.resize_to_fill PREVIEW_WIDTH * 2, preview_height * 2,
      gravity: :center
    preview = magick_cropped.resize_to_fill PREVIEW_WIDTH, preview_height,
      gravity: :center

    # preview_2x = magick_cropped.resize_to_fill PREVIEW_WIDTH * 2, preview_height * 2,
    #   crop: :centre
    # preview = magick_cropped.resize_to_fill PREVIEW_WIDTH, preview_height,
    #   crop: :centre

    mini_2x = magick_cropped.resize_to_fill MINI_WIDTH * 2, MINI_HEIGHT * 2,
      gravity: :center
    mini = magick_cropped.resize_to_fill MINI_WIDTH, MINI_HEIGHT,
      gravity: :center

    {
      main_2x: main_2x.convert!('webp'),
      main: main.convert!('webp'),
      main_alt_2x: main_2x.call!, # .convert!('png'), # .call!,
      main_alt: main.call!, # .convert!('png'), # .call!,
      preview_2x: preview_2x.convert!('webp'),
      preview: preview.convert!('webp'),
      preview_alt_2x: preview_2x.call!, # .convert!('png'), # .call!,
      preview_alt: preview.call!, # .convert!('png') # .call!
      mini_2x: mini_2x.convert!('webp'),
      mini: mini.convert!('webp'),
      mini_alt_2x: mini_2x.call!, # .convert!('png'), # .call!,
      mini_alt: mini.call! # .convert!('png') # .call!
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
