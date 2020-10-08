# rubocop:disable all
# TODO: delete everything. inline into BbCodes::Text
module CommentHelper
  include SiteHelper
  include Translation
  # include AniMangaHelper

  COMPLEX_BB_CODES = %i[
    smileys club club_page collection article contest mention version anime_video
    user review posters ban
  ]

  @@smileys_path = '/images/smileys/'
  @@smileys_synonym = {
    ':)' => ':-)'
  }
  @smiley_first_to_replace = [':dunno:']
  @@smiley_groups = [
    [':)', ':D', ':-D', ':lol:', ':ololo:', ':evil:', '+_+', ':cool:', ':thumbup:', ':yahoo:', ':tea2:', ':star:'],
    [':oh:', ':shy:', ':shy2:', ':hurray:', ':-P', ':roll:', ':!:', ':watching:', ':love:', ':love2:', ':bunch:', ':perveted:'],
    [':(', ':very sad:', ':depressed:', ':depressed2:', ':hopeless:', ':very sad2:', ':-(', ':cry:', ':cry6:', ':Cry2:', ':Cry3:', ':Cry4:'],
    [':-o', ':shock:', ':shock2:', ':scream:', ':dont want:', ':noooo:', ':scared:', ':shocked2:', ':shocked3:', ':shocked4:',
     ':tea shock:', ':frozen3:'],
    [':angry4:', ':revenge:', ':evil2:', ':twisted:', ':angry:', ':angry3:', ':angry5:', ':angry6:', ':cold:', ':strange4:', ':ball:', ':evil3:'],
    [':8):', ':oh2:', ':ooph:', ':wink:', ':dunno:', ':dont listen:', ':hypno:', ':advise:', ':bored:', ':disappointment:', ':hunf:'], # , ":idea:"
    [':hot:', ':hot2:', ':hot3:', ':stress:', ':strange3:', ':strange2:', ':strange1:', ':Bath2:', ':strange:', ':hope:', ':hope3:', ':diplom:'],
    [':hi:', ':bye:', ':sleep:', ':bow:', ':Warning:', ':Ban:', ':Im dead:', ':sick:', ':s1:', ':s3:', ':s2:', ':happy_cry:'],
    [':ill:',
     ':sad2:',
     ':bullied:', ':bdl2:',
     ':Happy Birthday:', ':flute:',
     ':cry5:',
     ':gaze:', ':hope2:',
     ':sleepy:',
     ':study:', ':study2:', ':study3:', ':gamer:',
     ':animal:',
     ':caterpillar:',
     ':cold2:', ':shocked:', ':frozen:', ':frozen2:', ':kia:', ':interested:',
     ':happy:',
     ':happy3:',
     ':water:', ':dance:', ':liar:', ':prcl:',
     ':play:',
     ':s4:', ':s:',
     ':bath:',
     ':kiss:', ':whip:', ':relax:', ':smoker:', ':smoker2:', ':bdl:', ':cool2:',
     ':V:', ':V2:', ':V3:',
     ':sarcasm:', ':angry2:', ':kya:']
  ]
  @@smileys = @@smiley_groups.flatten
  @@replaceable_smileys = @smiley_first_to_replace + (@@smileys.reverse - @smiley_first_to_replace)

  def smileys
    @@smileys
  end

  def smileys_path
    @@smileys_path
  end

  def smiley_groups
    @@smiley_groups
  end

  def smileys_to_html text, _poster = nil
    @@replaceable_smileys.each do |v|
      text.gsub!(v, format('<img src="%s%s.gif" alt="%s" title="%s" class="smiley" />', @@smileys_path, v, v, v))
    end
    text
  end

  def mention_to_html text, _poster = nil
    text.gsub /\[mention=(?<user_id>\d+)\](?<nickname>[\s\S]*?)\[\/mention\]/ do |match|
      nickname = $LAST_MATCH_INFO[:nickname]

      if nickname.present?
        url = profile_url User.param_to(nickname)
        "<a href='#{url}' class='b-mention'>"\
          "<s>@</s><span>#{nickname}</span></a>"
      else
        match
      end
    rescue ActionController::UrlGenerationError
      match
    end
  end

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
        "<a href=\"#{url_for entry}\" title=\"#{entry.name}\"><img class=\"poster-image\" src=\"#{ImageUrlGenerator.instance.url entry, :preview}\" srcset=\"#{ImageUrlGenerator.instance.url entry, :original} 2x\" title=\"#{entry.name}\" alt=\"#{entry.name}\"/></a>"
      else
        ''
      end
    end
  end

  # TODO: refactor to bbcode class
  @@type_matchers = {
    Version => [/(\[version(?:=(\d+))?\]([^\[]*?)\[\/version\])/, :tooltip_moderations_version_url],
    AnimeVideo => [/(\[anime_video(?:=(\d+))?\]([^\[]*?)\[\/anime_video\])/, :tooltip_anime_url],
    User => [/(\[(user|profile)(?:=(\d+))?\]([^\[]*?)\[\/(?:user|profile)\])/, nil],
    Review => [/(\[review=(\d+)\]([^\[]*?)\[\/review\])/, nil],
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
        if klass == Review
          begin
            review = Review.find($2)
            text.gsub!($1, "<a class=\"b-link\" href=\"#{url_for [review.target, review]}\" title=\"Обзор #{review.target.name} от #{review.user.nickname}\">#{$3}</a>")
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
              "<a href=\"#{profile_url user}\" class=\"b-user16\" title=\"#{$4}\"><img src=\"#{ImageUrlGenerator.instance.url user, :x16}\" srcset=\"#{ImageUrlGenerator.instance.url user, :x32} 2x\" alt=\"#{$4}\" /><span>#{$4}</span></a>" # +
              # (is_profile ? '' : wrote_html(user.sex))
            )
          rescue
            # text.gsub! $1, "#{$4}#{is_profile ? '' : " #{wrote_html('male')}"}"
            text.gsub! $1, $4
          end

        elsif klass == Ban
          begin
            ban = Ban.find $2

            moderator_html = "<div class=\"b-user16\"><a href=\"#{profile_url ban.moderator}\" title=\"#{ERB::Util.h ban.moderator.nickname}\">\
<img src=\"#{ImageUrlGenerator.instance.url ban.moderator, :x16}\" srcset=\"#{ImageUrlGenerator.instance.url ban.moderator, :x32} 2x\" alt=\"#{ERB::Util.h ban.moderator.nickname}\" /><span>#{ERB::Util.h ban.moderator.nickname}</span></a></div>"
            text.gsub! $1, "<br /><div class=\"ban\">#{moderator_html}: <span class=\"resolution\">#{ban.message}</span></div>"
          rescue ActiveRecord::RecordNotFound
            text.gsub! $1, ''
            text.strip!
          end

        else # [tag=id]name[/tag]
          begin
            id = $2.nil? ? $3.to_i : $2.to_i
            entry = klass.find(id)
            entry = entry.decorate unless entry.respond_to?(:name) # для AnimeVideo
            title = $2.nil? ? entry.name : $3

            additional = if preloader
              preloader_url = send preloader, (entry.kind_of?(AnimeVideo) ? entry.anime : entry)
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
              elsif entry.kind_of? AnimeVideo
                nil
              else
                url_for entry
              end

            if url
              text.gsub! $1, "<a href=\"#{url}\" title=\"#{entry.respond_to?(:name) ? entry.name : title}\"#{additional}>#{title}</a>"
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

  def wrote_html gender
    <<~HTML.tr("\n", '')
      <span class='text-ru'>#{i18n_v('wrote', 1, gender: gender, locale: :ru)}:</span>
      <span class='text-en' data-text='#{i18n_v('wrote', 1, gender: gender, locale: :en)}:'></span>
    HTML
  end
end
