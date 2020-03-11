class AnimeVideoDecorator < BaseDecorator
  HOSTINGS_ORDER = {
    'vk.com' => '_' * 1,
    'sovetromantica.com' => '_' * 2,
    'smotretanime.ru' => '_' * 3,
    'myvi.ru' => '_' * 4,
    'sibnet.ru' => '_' * 5,
    'rutube.ru' => '_' * 6,
  }

  # NOTE: используется в ./app/views/versions/_anime_video.html.slim
  def name
    "episode ##{episode} #{anime.name}"
  end

  def views_count
    if watch_view_count && watch_view_count > 0
      "#{watch_view_count} #{i18n_i 'view', watch_view_count}"
    end
  end

  def player_html
    if rejected? && !h.can?(:edit, object)
      return '<div class="player-placeholder"></div>'.html_safe
    end

    fixed_url = Url.new(url).without_protocol.to_s if url

    if (hosting == 'myvi.ru' && url.include?('flash')) ||
        (hosting == 'sibnet.ru' && url.include?('.swf?')) ||
        (hosting == 'i.ua')
      flash_player_html fixed_url

    elsif hosting == 'rutube.ru'
      if url =~ /\/\/video\.rutube.ru\/(.*)/
        # Простая фильтрация для http://video.rutube.ru/xxxxxxx
        if fixed_url.size > 30
          player_url_html "//rutube.ru/player.swf?hash=#{$1}"
        else
          player_url_html "//rutube.ru/play/embed/#{$1}"
        end
      else
        player_url_html url
      end

    elsif hosting == 'animaunt.ru'
      html5_video_player_html fixed_url

    else
      iframe_player_html fixed_url
    end
  end

  def player_url
    url
  end

  def in_list?
    user_rate.present?
  end

  def watched?
    in_list? && user_rate.episodes >= episode
  end

  def user_rate
    @user_rate ||= if h.user_signed_in?
      h.current_user.anime_rates.where(target_id: anime_id, target_type: Anime.name).first
    end
  end

  def sort_criteria
    [
      AnimeVideo.kind.values.index(kind),
      # unknown language приравниваем к russian language
      AnimeVideo.language.values.index(language.gsub('unknown', 'russian')),
      HOSTINGS_ORDER[hosting] || hosting,
      AnimeVideo.quality.values.index(quality),
      is_first ? 0 : 1,
      -id
    ]
  end

  # уникальность по [озвучка, хотинг, переводчик]
  def uniq_criteria
    [
      kind.fandub? || kind.unknown? ? '' : kind,
      vk? ? '' : hosting,
      language_english?
    ]
  end

  def watch_increment_delay
    (anime.duration.positive? ? anime.duration : 24) * 60_000 / 3
  end

  def versions
    @versions ||= VersionsQuery.by_item(object).transform(&:decorate).to_a
  end

private

  def player_url_html url
    h.content_tag(:div, class: 'player-placeholder') do
      h.content_tag(:div, class: 'inner') do
        h.content_tag(:a, class: 'player-url', href: url, target: '_blank') do
          url
        end +
        h.content_tag(:div, class: 'hint') do
          'Встраиваемый плеер не работает для этого хостинга. Для просмотра перейдите по ссылке выше.'
        end
      end
    end
  end

  def flash_player_html url
    h.content_tag(:object) do
      h.content_tag(:param, name: 'movie', value: "#{url}") {} +
      h.content_tag(:param, name: 'allowFullScreen', value: 'true') {} +
      h.content_tag(:param, name: 'allowScriptAccess', value: 'always') {} +
      h.content_tag(
        :embed,
        src: "#{url}",
        type: 'application/x-shockwave-flash',
        allowfullscreen: 'true',
        allowScriptAccess: 'always'
      ) {}
    end
  end

  def html5_video_player_html url
    h.content_tag(:video,
      src: url,
      controls: 'controls',
      autoplay: false
    ) {}
  end

  def iframe_player_html url
    h.content_tag(:iframe,
      src: url,
      frameborder: '0',
      webkitAllowFullScreen: 'true',
      mozallowfullscreen: 'true',
      scrolling: 'no',
      allowfullscreen: 'true'
    ) {}
  end
end
