#[posters animes=7054,20,50,49 colums=5]
class BbCodes::EntriesTag
  include Singleton
  include Draper::ViewHelpers

  REGEXP = /
    \[(?<type>animes|mangas|characters|people)
      (?:
        \s ids = (?<ids>[0-9,]+)
          |
        \s cover_notice = (?<cover_notice>studio|year_kind)
          |
        \s columns = (?<columns>[0-9]+)
          |
        \s (?<wall>wall)
      )+
    \]
  /imx
  DEFAULT_COLUMNS = 5
  MAX_ENTRIES = 300

  def format text
    # ограничение, чтобы нельзя было слишком много элементов вставить
    entries_count = 0

    text.gsub REGEXP do |matched|
      ids = $~[:ids].split(',').map(&:to_i)

      is_wall = $~[:wall].present?
      if is_wall
        columns = [[($~[:columns] || DEFAULT_COLUMNS).to_i, 6].max, 9].min
        cover_notice = :none
        cover_title = :none
      else
        columns = [[($~[:columns] || DEFAULT_COLUMNS).to_i, 4].max, 9].min
        cover_notice = ($~[:cover_notice] || 'none').to_sym
        cover_title = :present
      end

      entries_count += ids.size

      entries = fetch_entreis ids, type_to_klass($~[:type]), entries_count
      entries_html = entries.sort_by {|v| ids.index(v.id) }.map do |entry|
        entry_to_html entry, cover_title, cover_notice
      end

      if is_wall
        "<div class='cc-#{columns}-g0 align-posters unprocessed' data-columns='#{columns}'>#{entries_html.join ''}</div>"
      else
        "<div class='cc-#{columns} m0'>#{entries_html.join ''}</div>"
      end
    end
  end

private
  def entry_to_html entry, cover_title, cover_notice
    name = entry.class.name.downcase

    h.controller.request.env['warden'] ||= WardenStub.new
    h.controller.render_to_string(
      partial: "#{name.pluralize}/#{name}",
      locals: {
        "#{name}".to_sym => entry,
        cover_title: cover_title,
        cover_notice: cover_notice
      },
      formats: [:html]
    )
  end

  def fetch_entreis ids, klass, current_count
    klass
      .where(id: ids)
      .limit [0, MAX_ENTRIES - current_count].max
  end

  def type_to_klass type
    case type
      when 'animes' then Anime
      when 'mangas' then Manga
      when 'characters' then Character
      when 'people' then Person
    end
  end
end
