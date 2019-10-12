# legacy code
class TorrentsMatcher
  pattr_initialize :anime

  def matches_for title, options = { only_name: false, exact_name: false }
    title = title
      .delete('​')
      .tr('_', ' ')
      .tr('꞉', ':')
      .strip
      # .gsub(/^\[.*?\]\s*/, '')
      # .gsub(/\.(?:mkv|flv|mp4)/, '')
      # .gsub(/ - \d+ (?:\(|\[).*?(?:\)|\])/, '')

    if options[:exact_name] || anime.torrents_name.present?
      fixed_title = title.downcase.gsub(/[- :_]/, '')
      fixed_name = (anime.torrents_name || anime.name).downcase.gsub(/[- :_]/, '')
      return fixed_title.include? fixed_name
    end

    name_variants(title, options).any? do |query|
      query_keywords = query.keywords
      # long_query_keywords = query_keywords.select {|v| v.size > 2 }
      # query_keywords = long_query_keywords if long_query_keywords.size > 2 && long_query_keywords.size >= query_keywords.size/2
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
            overlaps.size >= (query_keywords.size.to_f / 2.5).floor) ||
            (query_keywords.size > 3 && overlaps.size >= (query_keywords.size.to_f / 2).ceil)
          ) && (query_specials & title.specials).size == query_specials.size
        end

      if matched
        parts = season_parts(query)

        if parts
          Regexp.new("#{parts[0]}[\\s\\W]#{parts[1]}").match(title)
        else
          true
        end
      else
        false
      end
    end
  end

  def name_variants agains = '', options = {}
    names = [anime.torrents_name || anime.name]
    unless options[:only_name] || anime.torrents_name
      unless anime.kind_special?
        names.concat([anime.english]) if anime.english.present?
        names.concat(anime.synonyms) if anime.synonyms.present?
      end
      names << anime.name.sub(/ (\d)$/, '\1') if anime.name =~ / \d$/
      names << anime.name.sub(/ (\d)$/, ' S\1') if anime.name =~ / \d$/
    end

    if names.any? { |v| v =~ / \(?(?:ova|tv|special|ona)\)?$/i }
      names = names.select { |v| v =~ / \(?(?:ova|tv|special|ona)\)?$/i }
    end

    names << anime.name + ' tv' if anime.name.match(':') && anime.kind_tv? && !anime.name.downcase.include?('tv') && agains.downcase.include?('tv')
    # случай, когда название содержит (tv)
    names << anime.name.sub(/\(tv\)/i, '').strip if anime.name.downcase.include? '(tv)'
    # тире воспринимаем так же, как пробел
    # 2 воспринимаем как II, а II как 2
    names = names.map do |name|
      [name, name.tr('-', ' ')].map { |v| [v.gsub(/\b2\b/, 'II'), v.gsub(/\bII\b/, '2')] }.flatten
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

    if /(\d|I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII|XIII)$/i.match?(season)
      [keyword.gsub(/\W/, ' ').split(' ').last, season]
    end
  end
end
