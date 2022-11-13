# rubocop:disable all
# TODO: delete everything. inline into BbCodes::Text
module CommentHelper
  include SiteHelper
  include Translation
  # include AniMangaHelper

  COMPLEX_BB_CODES = %i[
    club club_page collection article contest version
    user critique posters ban
  ]

  def remove_old_tags(html)
    html
      .gsub(/(?:<|&lt;)p(?:>|&gt;)[\t\n\r]*([\s\S]*?)[\t\n\r]*(?:<|&lt;)\/p(?:>|&gt;)/i, '\1')
      .gsub(/(?:<|&lt;)br ?\/?(?:>|&gt;)/, "\n")
      .strip
      # .gsub(/[\n\r\t ]+$/x, '')
  end

  def posters_to_html text, _poster = nil
    return text unless text.include?('[anime_poster') || text.include?('[manga_poster')

    text.gsub(/\[(anime|manga)_poster=(\d+)\]/) do
      entry = (Regexp.last_match(1) == 'anime' ? Anime : Manga).find_by_id(Regexp.last_match(2))
      if entry
        "<a href=\"#{url_for entry}\" title=\"#{ERB::Util.h entry.name}\"><img class=\"poster-image\" src=\"#{ImageUrlGenerator.instance.cdn_image_url entry, :preview}\" srcset=\"#{ImageUrlGenerator.instance.cdn_image_url entry, :original} 2x\" title=\"#{ERB::Util.h entry.name}\" alt=\"#{ERB::Util.h entry.name}\"/></a>"
      else
        ''
      end
    end
  end

  # TODO: refactor to bbcode class
  @@type_matchers = {
    Version => [/(\[version(?:=(\d+))?\]([^\[]*?)\[\/version\])/, :tooltip_moderations_version_url],
    User => [/(\[(user|profile)(?:=(\d+))?\]([^\[]*?)\[\/(?:user|profile)\])/, nil],
    Critique => [/(\[critique=(\d+)\]([^\[]*?)\[\/critique\])/, nil],
    Club => [/(\[club(?:=(\d+))?\]([^\[]*?)\[\/club\])/, nil],
    ClubPage => [/(\[club_page(?:=(\d+))?\]([^\[]*?)\[\/club_page\])/, nil],
    Collection => [/(\[collection(?:=(\d+))?\]([^\[]*?)\[\/collection\])/, nil],
    Article => [/(\[article(?:=(\d+))?\]([^\[]*?)\[\/article\])/, nil],
    Contest => [/(\[contest(?:=(\d+))?\]([^\[]*?)\[\/contest\])/, nil],
    Ban => [/(\[ban(?:=(\d+))\])/, nil]
  }
  @@type_matchers.each do |klass, (matcher, preloader)|
    define_method("#{klass.name.to_underscore}_to_html") do |text|
      while text =~ matcher
        if klass == Critique
          begin
            critique = Critique.find($2)
            text.gsub!(
              $1,
              "<a class=\"b-link\" " \
                "href=\"#{url_for [critique.target, critique]}\" " \
                "title=\"Обзор #{ERB::Util.h critique.target.name} " \
                "от #{ERB::Util.h critique.user.nickname}\">#{$3}</a>"
            )
          rescue
            text.gsub! $1, "<b>#{$3}</b>"
          end

        elsif klass == User
          is_profile = $2 == 'profile'
          begin
            user = if $3.nil?
              User.find_by nickname: $4
            else
              User.find $3
            end

            text.gsub!(
              $1,
              "<a href=\"#{profile_url user}\" class=\"b-user16\" " \
                "title=\"#{$4}\"><img " \
                "src=\"#{ImageUrlGenerator.instance.cdn_image_url user, :x16}\" " \
                "srcset=\"#{ImageUrlGenerator.instance.cdn_image_url user, :x32} 2x\" " \
                "alt=\"#{$4}\" /><span>#{$4}</span></a>"
            )
          rescue
            text.gsub! $1, $4
          end

        elsif klass == Ban
          begin
            ban = Ban.find $2

            moderator_html = "<div class=\"b-user16\"><a " \
              "href=\"#{profile_url ban.moderator}\" " \
              "title=\"#{ERB::Util.h ban.moderator.nickname}\"><img " \
              "src=\"#{ImageUrlGenerator.instance.cdn_image_url ban.moderator, :x16}\" " \
              "srcset=\"#{ImageUrlGenerator.instance.cdn_image_url ban.moderator, :x32} " \
              "2x\" alt=\"#{ERB::Util.h ban.moderator.nickname}\" " \
              "/><span>#{ERB::Util.h ban.moderator.nickname}</span></a></div>"
            text.gsub!(
              $1,
              "<br /><div class=\"ban\">#{moderator_html}: " \
                "<span class=\"resolution\">#{ban.message}</span></div>"
            )
          rescue ActiveRecord::RecordNotFound
            text.gsub! $1, ''
            text.strip!
          end

        else # [tag=id]name[/tag]
          begin
            id = $2.nil? ? $3.to_i : $2.to_i
            entry = klass.find(id)
            entry = entry.decorate unless entry.respond_to?(:name)
            entry_safe_name = ERB::Util.h(entry.name) if entry.respond_to?(:name)
            title = $2.nil? ? entry_safe_name : $3

            additional = if preloader
              preloader_url = send preloader, entry
              " class=\"bubbled b-link\" data-tooltip_url=\"#{preloader_url}\""
            else
              " class=\"b-link\""
            end

            url =
              if entry.kind_of? Version
                moderations_version_url entry
              elsif entry.kind_of? Club
                club_url entry
              elsif entry.kind_of? ClubPage
                club_club_page_url entry.club, entry
              else
                url_for entry
              end

            if url
              text.gsub! $1, "<a href=\"#{url}\" title=\"#{entry_safe_name || title}\"#{additional}>#{title.presence || entry_safe_name}</a>"
            else
              text.gsub! $1, title
            end

          rescue ActiveRecord::RecordNotFound
            text.gsub! $1, "<b>#{$3}</b>"
          end
        end
      end

      text
    end
  end
end
