class TorrentsMatcher
  pattr_initialize :anime

  # совпадает ли название аниме со строкой
  # для совпадения должны совпадать как минимум половина ключевых слов(если их меньше трех, то все)
  # и все спец слова
  # TODO: вынести из класса
  def matches_for title, options={ only_name: false, exact_name: false }
    title = title.gsub('​', '').gsub('_', ' ').gsub('꞉', ':')

    if options[:exact_name] || anime.torrents_name.present?
      fixed_title = title.downcase.gsub(/[- :_]/, '')
      fixed_name = (anime.torrents_name || name).downcase.gsub(/[- :_]/, '')
      return fixed_title.include? fixed_name
    end

    name_variants(title, options).any? do |query|
      query_keywords = query.keywords
      #long_query_keywords = query_keywords.select {|v| v.size > 2 }
      #query_keywords = long_query_keywords if long_query_keywords.size > 2 && long_query_keywords.size >= query_keywords.size/2
      next if query_keywords.empty?
      title_keywords = title.keywords
      query_specials = query.specials
      overlaps = query_keywords & title_keywords

      matched =
        if options[:only_name]
          overlaps.size == query_keywords.size
        else
          ((query_keywords.size <= 3 && overlaps.size == query_keywords.size) ||
            (query_keywords.size > 6 &&
            query_keywords.include?('tv') &&
            title_keywords.include?('tv') &&
            overlaps.size >= (query_keywords.size.to_f/2.5).floor) ||
            (query_keywords.size > 3 && overlaps.size >= (query_keywords.size.to_f/2).ceil)
          ) && (query_specials & title.specials).size == query_specials.size
        end

#ap [query, query_keywords, title_keywords, matched, season_parts(query)]

      if matched
        parts = season_parts(query)
        if parts
          Regexp.new("%s[\\s\\W]%s" % parts).match(title)
        else
          true
        end
      else
        false
      end
    end
  end

  # все вариации названий аниме
  def name_variants agains='', options={}
    names = [anime.torrents_name || anime.name]
    unless options[:only_name] || anime.torrents_name
      unless anime.kind_special?
        names.concat(anime.english) unless !anime.english || anime.english.empty?
        names.concat(anime.synonyms) unless !anime.synonyms || anime.synonyms.empty?
      end
      names << anime.name.sub(/ (\d)$/, '\1') if anime.name =~ / \d$/
      names << anime.name.sub(/ (\d)$/, ' S\1') if anime.name =~ / \d$/
    end

    names = names.select {|v| v =~ / \(?(?:ova|tv|special|ona)\)?$/i } if names.any? {|v| v =~ / \(?(?:ova|tv|special|ona)\)?$/i }
    names << anime.name + ' tv' if anime.name.match(':') && anime.kind_tv? && !anime.name.downcase.include?('tv') && agains.downcase.include?('tv')
    # случай, когда название содержит (tv)
    names << anime.name.sub(/\(tv\)/i, '').strip if anime.name.downcase.include? '(tv)'
    # тире воспринимаем так же, как пробел
    # 2 воспринимаем как II, а II как 2
    names = names.map do |name|
      [name, name.gsub('-', ' ')].map {|v| [v.gsub('2', 'II'), v.gsub('II', '2')] }.flatten
    end

    ['☆', '/', '†', '♪', '.'].each do |symbol|
      if anime.name.include? symbol
        names << anime.name.gsub(symbol, '')
        names << anime.name.gsub(symbol, ' ')
      end
    end
    names.flatten.uniq
  end

private

  def season_parts(title)
    parts = title.split(' ')
    return nil if parts.size < 2
    season = parts[parts.size - 1]
    keyword = parts[parts.size - 2]
    if season =~ /(\d|I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII|XIII)\b/
      [keyword.gsub(/\W/, ' ').split(' ').last, season]
    else
      nil
    end
  end
end
