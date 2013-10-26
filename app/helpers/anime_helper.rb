module AnimeHelper
  # время выхода следующей серии
  def time_of_next_episode(anime, main_page=false)
    episode_start = if anime.status == AniMangaStatus::Anons
      (anime.episode_start_at || anime.aired_at).to_datetime
    else
      anime.next_release_at || anime.episode_start_at || (anime.episodes_news.any? ? anime.episodes_news.sort_by {|v| - v.created_at.to_i }.first.created_at : anime.aired_at) + anime.average_interval
    end
    episode_end = anime.next_release_at || anime.episode_end_at || (anime.episodes_news.any? ? anime.episodes_news.sort_by {|v| - v.created_at.to_i }.first.created_at : anime.aired_at) + anime.average_interval
    now = DateTime.now

    # идёт ли показ прямо сейчас?
    if episode_start <= now && episode_end >= now
      'сейчас на ТВ'
    # пока завершён?
    elsif episode_end < now
      # знаем ли точное время эпизода?
      if anime.episode_end_at
        if main_page
          "было на ТВ %s" % time_ago_in_words(anime.episode_end_at, "%s назад").sub(" #{DateTime.now.year}", '')
        else
          str = "%s" % time_ago_in_words(anime.episode_end_at, "%s назад").sub(" #{DateTime.now.year}", '').sub('около ', '')
          if str =~ /час/
            hours = str.match(/\d+/)[0].to_i
            Russian.p(hours, "#{hours} час назад", "#{hours} часа назад", "#{hours} часов назад")
          else
            str
          end
        end
      # не знаем
      else
        ago = time_ago_in_words(episode_end)
        if ago =~ /\d\d\d\d$/
          ago
        else
          "задержка #{ago}"
        end
      end
    # показ ещё не стартовал
    else
      # знаем ли точное время эпизода?
      if anime.episode_end_at || (main_page && DateTime.now + 1.day > episode_end)
        # главная ли это страница?
        if main_page
          "до показа %s" % time_ago_in_words(episode_start).sub('осталось 1 день', 'остался 1 день')
        # не главная
        else
          "#{"показ " if main_page}с #{anime.episode_start_at.strftime('%H:%M')} по #{anime.episode_end_at.strftime('%H:%M')}"
        end
      # не знаем
      else
        episode_end.strftime("#{"ожидаемое время " if main_page}%H:%M")
      end
    end
  end

  def truncate_studio(name)
    name.sub(/^(studio|production) /i, '').split(" ")[0]
  end

  def name_font(name, offset=0)
    if name.size >= 30
      "f16"
    elsif name.size >= 14
      "f17"
    else
      "f18"
    end
    #if name.size >= 30
      #"f%d" % [18-offset]
    #elsif name.size >= 14
      #"f%d" % [20-offset]
    #else
      #"f%d" % [24-offset]
    #end
  end

  def history_link_to(klass, id, title, type)
    link_to title, {:controller => klass.name.tableize, :action => :index, :genre => nil, :type => nil, :studio => nil, :season => nil, :order => nil, :page => nil}.merge(type => id), :rel => 'nofollow'
  end

  def humanize_users(count)
    if count % 10 == 1 && (count/10) % 10 != 1
      'пользователя'
    else
      'пользователей'
    end
  end

  def humanize_minutes(minutes)
    return "0 мин." if minutes == 0
    text = ""

    hours = (minutes/60).floor.to_i
    text += "%i час" % hours if hours == 1
    text += "%i часа" % hours if hours > 1 && hours < 5
    text += "%i часов" % hours if hours > 4

    raw_minutes = minutes % 60
    text += " " if hours > 0 && raw_minutes > 0

    if raw_minutes > 0
      if raw_minutes % 10 == 1
        text += "%i мин." % raw_minutes
      elsif raw_minutes % 10 > 1 && raw_minutes % 10 < 5
        text += "%i мин." % raw_minutes
      else
        text += "%i мин." % raw_minutes
      end
    end

    text
  end

  def person_tooltip_class(person)
    if person.class == UserChange || (
           person.image.exists? && ((person.description_mal && !person.description_mal.empty?) || (person.description && !person.description.empty?) || person.class == Character)
         )
      "person-tooltip-full"
    elsif person.image.exists? && !((person.description_mal && !person.description_mal.empty?) || (person.description && !person.description.empty?))
      "person-tooltip-image"
    else
      "person-tooltip-none"
    end
  end

  # TODO: refactor this shit
  def person_tooltip_text(person, with_seyu=true, no_format=false)
    return "" unless person.image.exists? || (person.description_mal && !person.description_mal.empty?) || (person.description && !person.description.empty?)

    text = '<div class="block-title">'
    person_name = if person.respond_to?(:russian) && person.russian.present?
      [person.name, person.russian].compact.join(' / ')
    else
      person.name || person.title
    end
    text += "<div class=\"title\" title=\"%s\">%s</div>" % [
      h(person_name),
      person_name
    ]
    text += "</div>"
    if person.image.exists?
      text += "<a href=\"#{url_for(person)}\">"
      text += "<img src=\"%s\" title=\"%s\" class=\"tooltip-img\">" % [person.image.url, person[:name] || person.name]
      text += "</a>"
    end
    #text += "<span class=\"created\">10/01/2009</span>"
    text += "<div class=\"tooltip-desc\">"
    if with_seyu && person.class == Character && !person.seyu.empty?
      text += "<div class=\"person-block item-block\">"
      text += render :partial => 'blocks/person_content.html.erb', :locals => {:person => person.seyu.first, :role => 'Japanese', :link_to_seyu => true}
      text += "</div>"
    end

    if person.description || person.description_mal
      description = if person.respond_to?(:description_html) && person.description_html.present?
        person.description_html
      elsif !person.respond_to?(:source) || person[:description].blank?
        remove_misc_data(person.description.blank? ? person.description_mal : person.description)
      else
        BbCodeService.instance.format_comment person.description.blank? ? person.description_mal : person.description
      end
      text += truncate_html description, :length => 750, :separator => ' ', word_boundary: /\S[\.\?\!]/
    end
    text += "</div>"
    #text += "<div class=\"tooltip-restrictions\">This video is available for Anime Members only.</div>"

    no_format ? text : format_tooltip(text)
  end

  def truncate_html(text, options)
    super(text.gsub('№', 'CODE_N').gsub('°', 'CODE_PER'), options).gsub('CODE_N', '№').gsub('CODE_PER', '°')
  end

  def format_person_role(role, options = { full: false })
    roles = role.split(/, */)
    if roles.size > 1
      if options[:full]
        return roles.map {|v| t "Role.%s" % v }.sort.join(', ')
      else
        return "%s (+)" % (t "Role.%s" % roles.first)
      end
    else
      return t "Role.%s" % roles.first
    end
  end

  def average_score(scores)
    return '' unless scores
    return '' if scores.respond_to?(:[]) && !scores.kind_of?(Fixnum) && (scores.empty? || scores.sum == 0)
    return scores unless scores.respond_to?(:[]) && !scores.kind_of?(Fixnum)
    total = 0
    scores.each_with_index do |v,k|
      total += (k+1)*v
    end
    "%.2f" % [total*1.0 / scores.sum]
  end

  def format_tooltip(text=nil, &block)
    tooltip_text = "<div class=\"tooltip-inner\">"
    tooltip_text += "  <div class=\"tooltip-arrow\">"
    tooltip_text += "  </div>"
    tooltip_text += "  <div class=\"clearfix\">"
    tooltip_text += "    <div class=\"tooltip-details\">"
    tooltip_text += block_given? ? capture(&block) : text
    tooltip_text += "    </div>"
    tooltip_text += "  </div>"
    tooltip_text += "  <div class=\"dropshadow-top\"></div>"
    tooltip_text += "  <div class=\"dropshadow-top-right\"></div>"
    tooltip_text += "  <div class=\"dropshadow-right\"></div>"
    tooltip_text += "  <div class=\"dropshadow-bottom-right\"></div>"
    tooltip_text += "  <div class=\"dropshadow-bottom\"></div>"
    tooltip_text += "  <div class=\"dropshadow-bottom-left\"></div>"
    tooltip_text += "  <div class=\"dropshadow-left\"></div>"
    tooltip_text += "  <div class=\"dropshadow-top-left\"></div>"
    tooltip_text += "</div>"
    tooltip_text
  end
end
