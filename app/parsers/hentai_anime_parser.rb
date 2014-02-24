class HentaiAnimeParser < FindAnimeParser
  PageSize = 60

  #def initialize
    #super
    #@proxy_log = true
  #end

  def extract_names entry, doc
    h1_tag = doc.css('h1').first()
    entry[:names] = h1_tag
      .text
      .split("\n")
      .map(&:strip)
      .select(&:present?)
      .second
      .sub(/ онлайн$/, '')
      .split(/[)(]/)
      .map(&:strip)

    entry[:russian] = entry[:names].find(&:contains_russian?)

    entry[:names] += entry[:names].second.split(/ *: */) if entry[:names].second =~ /:/
  end

  def extract_additional entry, doc
    super
    entry[:year] ||= $~[:year].to_i if doc.css('.elementList').to_s.match /Год выпуска:[\s\S]*?(?<year>\d+)<\/a>/
  end

private
  def domain
    'hentai-anime.ru'
  end

  def chapters_selector
    '.expandable table a'
  end
end
