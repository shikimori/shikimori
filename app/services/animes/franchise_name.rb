class Animes::FranchiseName
  method_object :entries, :taken_names

  ALLOWED_SHORT_NAMES = %w[
    ef
    ga
    k
    mm
    x
    ys
  ]

  FIXED_NAMES = {
    'initial d first stage' => 'initial_d',
    'tales of the abyss' => 'tales_of',
    'chaos;head' => 'science_adventure',
    'fate/zero' => 'fate',
    'fate/apocrypha' => 'fate',
    'the idolm@ster' => 'idolmaster',
    '.hack//sign' => 'hack',
    'ore no imouto ga konnani kawaii wake ga nai' => 'ore_no_imouto',
    'maria-sama ga miteru' => 'maria_sama',
    'kyoushoku soukou guyver' => 'guyver',
    'aria the natural' => 'aria',
    'marvel future avengers' => 'marvel',
    're:zero kara hajimeru isekai seikatsu' => 're_zero',
    'dungeon ni deai wo motomeru no wa machigatteiru darou ka' => 'danmachi',
    'Tales of Crestoria' => 'tales_of',
    'Bakuman.' => 'bakuman',
    'Detective Conan' => 'detective_conan',
    'Saki' => 'saki',
    'Nanatsu no Tanpen' => 'nanatsu_no_tanpen',
    'Fairy Tail' => 'fairy_tail',
    'Boku wa Tomodachi ga Sukunai' => 'boku_wa_tomodachi_ga_sukunai',
    'Higurashi no Naku Koro ni Kai' => 'when_they_cry',
    'Binan Koukou Chikyuu Bouei-bu LOVE! LOVE! LOVE!' => 'binan_koukou_chikyuu_boueibu_love',
    'Monster Strike' => 'monster_strike',
    'Mameshiba 2nd Season' => 'mameshiba',
    'Daisuki! Hello Kitty' => 'hello_kitty',
    'Tennis no Oujisama' => 'tennis_no_ouji_sama',
    'Cutie Honey' => 'cutey_honey',
    'Hello Kitty no Cinderella' => 'hello_kitty',
    'Haou Taikei Ryuu Knight' => 'haou_daikei_ryuu_knight',
    'Kidou Keisatsu Patlabor' => 'mobile_police_patlabor',
    'Douluo Dalu' => 'soul_land'
  }.transform_keys(&:downcase)

  def call
    # ap entries.map(&:id)
    # ap extract_names(entries)

    present_franchise ||
      new_franchise(true) ||
      new_franchise(false)
  end

private

  def extract_names entries
    entries
      .reject { |v| v.anime? && (v.kind_special? || v.kind_music?) }
      .flat_map { |v| [v.name, v.english].compact.uniq }
      .flat_map { |name| multiply_names name }
      .compact
      .select { |name| name.size > 2 || ALLOWED_SHORT_NAMES.include?(name) }
      .uniq
  end

  def present_franchise
    current_name =
      @entries
        .group_by(&:franchise)
        .reject do |name, entries|
          entries.size < @entries.size / 2.0 ||
            Animes::BannedFranchiseNames.instance.include?(name)
        end
        .first
        &.first

    if current_name && extract_names(@entries).include?(current_name)
      current_name
    end
  end

  def new_franchise do_filter
    names = extract_names(do_filter ? filter(@entries) : @entries)
      .reject { |name| @taken_names.include? name }
      .reject { |name| Animes::BannedFranchiseNames.instance.include? name }

    names.find { |name| FIXED_NAMES.value? name } ||
      names.min_by(&:length)
  end

  def cleanup name, special_regexp
    name
      .downcase
      .tr(' ', '_')
      .gsub(special_regexp, '')
      .gsub(/[^A-z0-9]/, '_')
      .gsub(special_regexp, '')
      .gsub(/_ova\b/, '')
      .gsub(/__+/, '_')
      .gsub(/^_|_$/, '')
  end

  def filter entries
    if entries.first.anime?
      entries.reject { |v| v.kind_special? || v.kind_music? }
    else
      entries.reject { |v| v.kind_one_shot? || v.kind_doujin? }
    end
  end

  def multiply_names name
    [
      FIXED_NAMES[name.downcase],
      cleanup(name, //),
      cleanup(name, /:.*$/),
      cleanup(name, /!.*$/),
      cleanup(name, /(_\d+)+$/),
      cleanup(name, /_i+$/)
    ]
  end
end
