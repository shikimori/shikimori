class IdzumiReviewsJob < JobWithRestart
  def do
    Topic.wo_antispam do
      import
    end
  end

  def import
    Proxy.use_cache = true
    Proxy.use_proxy = false
    Proxy.show_log = true

    one_added = false

    kinds.keys.each do |kind|
      content = Proxy.get "http://zerkalo-anime.org/#{kind}/"
      doc = Nokogiri::HTML content
      links = doc.css('tr.sectiontableentry1 a,tr.sectiontableentry2 a').map {|v| 'http://zerkalo-anime.org' + v.attr('href') }

      links.shuffle.each do |url|
        content = Proxy.get url
        doc = Nokogiri::HTML content
        name = doc.css('.title_eng').text
        name = matchers[name] if matchers.include? name
        fixed_name = fix_name(name)

        entries = kinds[kind].select { |v| fix_name(v.name) == fixed_name || v.english.any? { |v| fix_name(v) == fixed_name } || v.synonyms.any? { |v| fix_name(v) == fixed_name } }
        entries = kinds[kind].select { |v| v.id == 958 } if name == 'Goth'
        entries = kinds[kind].select { |v| v.id == 5858 } if name == 'Doubt'
        entries = kinds[kind].select { |v| v.id == 16965 } if name == 'Портрет'

        if entries.count > 1
          raise "больше одного совпадения для #{name} (#{url})"
        end
        if entries.empty?
          raise "нет совпадений для #{name} (#{url})"
        end

        review = Review.new
        review.target_type = kind.capitalize
        review.target_id = entries.first.id
        review.user_id = idzumi.id
        next if idzumi.reviews.any? { |v| v.target_type == review.target_type && v.target_id == review.target_id }
        review.source = url
        #review.created_at = 2.weeks.ago
        #review.updated_at = 2.weeks.ago
        #review.scores_on_top = false

        texts = doc.css('.component_box').inner_html.strip.sub(/<p>© Idzumi.*/, '').strip.split(/<p.*?>/).select(&:present?).map{|v| v.sub('</p>', '') }.map(&:strip)
        annotation = '[right][i][size=12][color=#7B8084]' + texts[0].split('<br>').join("[/color][/size][/i][/right] [right][i][size=12][color=#7B8084]") + "[/color][/size][/i][/right]\n"
        annotation = annotation.sub('[right][i][size=12][color=#7B8084]<strong>', '[right][size=11][color=#666666]').sub('</strong>[/color][/size][/i]', '[/size][/color]')

        review.text = annotation + texts.slice(1, 99).join("\n")
        review.save!(validate: false)

        one_added = true
        break
      end
      break if one_added
    end

    Proxy.use_cache = false
    Proxy.use_proxy = true
    Proxy.show_log = false

    raise "nothing was added" unless one_added
  end

  def fix_name(name)
    name.gsub(/[\W]/, '').downcase
  end

  def animes
    @animes ||= Anime.all
  end

  def mangas
    @mangas ||= Manga.all
  end

  def kinds
    @kinds ||= {'anime' => animes, 'manga' => mangas}
  end

  def idzumi
    @idzumi ||= User.find 2357
  end

  def matchers
    @matchers ||= {
      'Hell Girl: Second Cage' => 'Jigoku Shoujo Futakomori',
      'Ayakashi: Samurai Horror Tales' => 'Ayakashi: Japanese Classic Horror',
      'Vision of Escaflowne: The Movie' => 'Escaflowne: A Girl in Gaea',
      'Cat\'s Return' => 'Neko no Ongaeshi',
      'Peacemaker' => 'Peace Maker Kurogane',
      'Planet of the Beast King' => 'Jyu Oh Sei',
      'Weathering Continent' => 'Kaze no Tairiku',
      'Gensomaden Saiyuki: Requiem' => 'Saiyuki: Requiem',
      'XXXHOLiC: Kei' => 'xxxHOLiC Kei',
      'Genshiken TV' => 'Genshiken',
      'Beyond the Clouds, The Promised Place' => 'The Place Promised in Our Early Days',
      'Demon Detective Loki Ragnarok' => 'Matantei Loki Ragnarok',
      'Nausicaa of the Valley of Wind' => 'Kaze no Tani no Nausicaa',
      'Laputa: The Castle in the Sky' => 'Tenkuu no Shiro Laputa',
      'Ghost in the Shell II: Innocence' => 'Ghost in the Shell 2: Innocence',
      'Kino no Tabi' => 'Kino no Tabi: The Beautiful World',
      'Gensomaden Saiyuki TV' => 'Gensou Maden Saiyuuki',
      'Fullmetal Alchemist: Conqueror of Shambala' => 'Fullmetal Alchemist: The Conqueror of Shamballa',
      'She and Her Cat' => 'Kanojo to Kanojo no Neko'
    }
  end
end
