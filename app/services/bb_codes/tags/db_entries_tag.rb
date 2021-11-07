# [posters animes=7054,20,50,49 colums=5]
class BbCodes::Tags::DbEntriesTag
  include Singleton
  include Draper::ViewHelpers

  REGEXP = /
    \[(?<type>animes|mangas|ranobe|characters|people)
      (?:
        \s ids = (?<ids>[0-9,]+)
          |
        \s cover_notice = (?<cover_notice>studio|year_kind)
          |
        \s columns = (?<columns>[0-9]+)
          |
        \s class = (?<css_class>[\w_-]+)
          |
        \s (?<wall>wall)
      )+
    \] \n?
  /imx
  DEFAULT_COLUMNS = 8
  MAX_ENTRIES = 500

  def format text
    # ограничение, чтобы нельзя было слишком много элементов вставить
    entries_count = 0

    text.gsub REGEXP do |_matched|
      ids = $LAST_MATCH_INFO[:ids].split(',').map(&:to_i).select { |v| v < 2_147_483_647 }
      css_class = BbCodes::CleanupCssClass.call $LAST_MATCH_INFO[:css_class]

      is_wall = $LAST_MATCH_INFO[:wall].present?
      if is_wall
        columns = [[($LAST_MATCH_INFO[:columns] || DEFAULT_COLUMNS).to_i, 6].max, 9].min
        cover_notice = :none
        cover_title = :none
      else
        columns = [[($LAST_MATCH_INFO[:columns] || DEFAULT_COLUMNS).to_i, 4].max, 9].min
        cover_notice = ($LAST_MATCH_INFO[:cover_notice] || 'none').to_sym
        cover_title = :present
      end

      if ids.size + entries_count > MAX_ENTRIES
        next "[color=red]limit exceeded (#{MAX_ENTRIES} max)[/color]"
      end

      entries_count += ids.size

      entries = fetch_entries ids, type_to_klass($LAST_MATCH_INFO[:type]), entries_count
      entries_html = entries.sort_by { |v| ids.index(v.id) }.map do |entry|
        entry_to_html entry, cover_title, cover_notice
      end

      if is_wall
        css_class ||= "cc-#{columns}-g0"

        "<div class='#{css_class} to-process' data-dynamic='aligned_posters' " \
          "data-columns='#{columns}'>#{entries_html.join}</div>"

      else
        klass ||= "cc-#{columns}#{'-g15' if columns >= 6}"
        ratio_type = [Character, Person].include?(type_to_klass($LAST_MATCH_INFO[:type])) ?
          " data-ratio_type='person'" :
          ''

        "<div class='#{klass} m0 to-process' "\
          "data-dynamic='cutted_covers'#{ratio_type}>#{entries_html.join}</div>"
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
        name.to_s.to_sym => entry.decorate,
        cover_title: cover_title,
        cover_notice: cover_notice
      },
      formats: [:html],
      cached: ->(model) { CacheHelper.keys model, cover_title, cover_notice }
    )
  end

  def fetch_entries ids, klass, _current_count
    klass.where(id: ids)
  end

  def type_to_klass type
    case type.downcase
      when 'animes' then Anime
      when 'mangas' then Manga
      when 'ranobe' then Ranobe
      when 'characters' then Character
      when 'people' then Person
    end
  end
end
