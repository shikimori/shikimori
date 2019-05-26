#!/usr/bin/env ruby
puts 'loading rails...'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

def cleanup name
  name
    .gsub(/\(.*/, '')
    .gsub(/\.(?:tv|ru|com|net|online|su)/i, '')
    .gsub(/SovetRomanticа|SоvetRomantica/i, 'SovetRomantica')
    .gsub(/японская таверна/i, 'Японская Таверна')
    .gsub(/3df_voice/i, '3df voice')
    .gsub(/aos.*/i, 'AOS')
    .gsub(/tycoon(-| )studio/i, 'Tycoon')
    .gsub(/Uncle Ho/i, 'Uncle_Ho')
    .gsub(/SE-Team/i, 'SE Team')
    .gsub(/anigakudub/i, 'AnigaKuDub')
    .gsub(/anime(\s|-)?group/i, 'AnimeGroup')
    .gsub(/anything(\s|-)?group/i, 'Anything Group')
    .gsub(/animespirit fandub team/i, 'AnimeSpirit')
    .gsub(/anipaladin/i, 'Anipaladin')
    .gsub(/anivoice/i, 'ANIVoice')
    .gsub(/Arasi_project/i, 'Arasi Project')
    .gsub(' / Одноголосная', '')
    .strip
    .gsub(/^&\s*|^[-~(+*_#@]|[-~)+*_#@]$/, '')
    .gsub(/озвучено\s*/i, '')
    .gsub(/\s*:.*/i, '')
    .gsub(/(\s)\s+/, '\1')
    .gsub('Е.Лурье', 'Е. Лурье')
    .gsub('AleX MytH', 'AleX_MytH')
    .gsub('AniENTERNAL', 'AniEnternal')
    .gsub('AniStar 18', 'AniStar')
    .strip
end

def ignored? name, size
  return true if name.blank?

  [
    'госкино СССР',
    'СПЕЦВЫПУСК',
    'СТС',
    'СТС-Love',
    'СТС Love',
    'ВидеоСервис',
    'НТВ Плюс',
    'тв-3',
    '5.1',
    'слабо вк добавлять',
    '4 of 4',
    'AMV',
    'AML',
    'ANE',
    'anonim',
    'Any0ne',
    'AOS',
    'Asura',
    'Asura Cryin\' 2 2009',
    'ETB',
    'FAN',
    'HWP',
    'ANS',
    'ART',
    'ASF',
    '16Б',
    'МБВМ',
    'МФТИ',
    'Новый канал',
    'ОРТ',
    'NNK',
    'rutracker.org',
    'UTW',
    'Макс 1',
    'Многоголосная',
    'Многоголосый',
    'V-A',
    'XviD_704x396',
    'полный фильм',
    'Первый Канал',
    'Проф',
    'Профессионально',
    'Профессиональное',
    'Профессиональный',
    'Разноцветные',
    'Рус. озв',
    'Рус.озв.',
    'Судьба.',
    'татикомы',
    'ТНТ',
    'Титры',
    'Французская',
    'Рабочий Стол',
    'Bistriy',
    'Андрей',
    'высокое качество',
    'вхсрип',
    'Временные',
    'OPT',
    'anime.aplus.by',
  ].include?(name) ||
    name.size <= 2 ||
    (size <= 3 && name.size <= 10) ||
    name.match?(/^([\dxхp.+ -]+|tvrip|vhsrip|bdrip|ru|jp|jpn)\b/i) ||
    name.match?(/^(rus|en|to|tor)\b/i) ||
    name.match?(/^anime$/i) ||
    name.match?(/\b(xvid|rip|ru|en|rus|jap|jp|en|англ|даб|этти|хз|ova|tv|суб|ru_jp|ru_ru|rus_jap|rus_jpn)\b/i) ||
    name.match?(/легенда о героях галактики|лирический ангел/i) ||
    name.match?(/
      сери(и|я) | неизвестный | новая версия | эпизод | ова | овы |
      украинс | русск | ансаб | дубляж |
      озвучил | отрывок |
      двухголосая | девочка | дублированный | полный фильм
      2x2 | 2х2 | полные | многоголосая | английск |
      субтитры | часть | спешл | полные | озвучк | перевод | озвучек |
      субитир | надписи | сабы | srt | ass |
      \bч\.\b | \bэп\. | \bсаб\.
    /mix)
end

def enough? anime, size
  if anime.ongoing?
    if anime.episodes_aired > 300
      size >= 40
    elsif anime.episodes_aired > 52
      size >= 20
    elsif anime.episodes_aired >= 20
      size >= 7
    elsif anime.episodes_aired >= 10
      size >= 4
    elsif anime.episodes_aired >= 5
      size >= 3
    else
      size > 1
    end
  else
    if anime.episodes > 300
      size >= 40
    elsif anime.episodes > 52
      size >= 20
    elsif anime.episodes >= 20
      size >= 7
    elsif anime.episodes >= 10
      size >= 4
    elsif anime.episodes >= 5
      size >= 3
    else
      true
    end
  end
end

Chewy.strategy(:bypass) do
  Anime
    .where(id: AnimeVideo.pluck('distinct(anime_id)'))
    .order(id: :desc)
    .each do |anime|
      next if (anime.kind == 'special' && anime.episodes < 5) || (anime.kind == 'ova' && anime.episodes < 3)

      AnimeVideo
        .where(anime_id: anime.id)
        .where.not(anime_video_author_id: nil)
        .where(language: 'russian')
        .where(kind: %i[unknown subtitles fandub])
        .includes(:author)
        .group_by(&:subtitles?)
        .each do |is_subtitles, anime_videos|
          groups = anime_videos
            .group_by { |anime_video| cleanup anime_video.author.name }
            .map { |name, videos| [name, videos.uniq(&:episode)] }
            .reject { |name, videos| ignored? name, videos.size }
            .reject { |name, _videos| anime.name.downcase.include?(name.downcase) }
            .reject { |name, _videos| anime.russian.present? && anime.russian.downcase.include?(name.downcase) }
            .reject { |name, _videos| anime.english.present? && anime.english.include?(name.downcase) }
            .select { |_name, videos| enough? anime, videos.size }

          anime.update!(
            is_subtitles ? :fansubbers : :fandubbers =>
              groups.map { |name, videos|  "#{name} #{videos.size}" }
              # groups.map { |name, _videos| name } # "#{name} #{videos.size}" }
          )
        end
  end
end
