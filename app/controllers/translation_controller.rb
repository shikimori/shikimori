class TranslationController < GroupsController
  # список аниме на перевод
  def index
    @translate_ignore = [19067,19157,21447,3447,3485,2448,1335,8648,1430,1412,1425,10029,597,1029,7711,1972,1382,10444,10370,10349,10359,10347,10324,10257,10015,10533,10499,10507,10444,10177,9441,7761,5032,7463,7723,6582,6604,5670,5973,5460,1367,1364,781,1506,1363,372,1430,3014,3016,6467,2448,1366,4985,283,10797,10802,10847,10997,11017,15865,15545,14631,10694,14947,15537,18469,18097,18357,18355,13029,13231,12979,9204,19291,10703,10531,12963,16287,17141,17497,17703,17969,18227,17705,19099]
    @translate_me = []
    @goals = []
    #@goals2 = {}
    @goals << ['Top 50 TV',
               Anime.where(:id =>
                       Anime.where(kind: 'TV').
                             where { ranked.not_eq 0 }.
                             order(:ranked).limit(50).
                             pluck(:id)
                     ).
                     where { id.not_in Anime::EXCLUDED_ONGOINGS }.
                     where { id.not_in my{@translate_ignore} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Top 20 OVA',
               Anime.where(id: Anime.where("kind != 'TV' and kind != 'Movie'").where { ranked.not_eq 0 }.order(:ranked).limit(40).pluck(:id)).
                     where { id.not_in Anime::EXCLUDED_ONGOINGS }.
                     where { id.not_in my{@translate_ignore} }.
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked).
                     limit(20)]
    @goals << ['Top 30 Movies',
               Anime.where(id: Anime.where(kind: 'Movie').where { ranked.not_eq 0 }.order(:ranked).limit(100).pluck(:id)).
                     where { id.not_in Anime::EXCLUDED_ONGOINGS }.
                     where { id.not_in my{@translate_ignore} }.
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked).
                     limit(30)]
    #9201, 540, 4188, 6904
    @goals << ['На первой странице жанра',
               Anime.where(id: [2835,2034,1729,3750,444,795,1569,1382,4188,540,268,4188,2559,11077,6904,666,2158,3907,1089,3665,85,401,2951,1092,813,6171,6811,535,1172,6793,60,5671,658,437,10083,4163,2951,8063,8634,5774,5719,741,5902,734,795,855,667,6331]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Онгоинги',
               Anime.translatable.
                     where(status: AniMangaStatus::Ongoing).
                     where('score != 0 && ranked != 0').
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in [10908,11385] }.
                     where { id.not_in my{@translate_ignore} }.
                     where(censored: false).
                     order(:ranked).
                     limit(15)]
    @goals << ['Сериалы',
               Anime.where(id: AniMangaQuery::AnimeSerials).
                     where { id.not_in Anime::EXCLUDED_ONGOINGS }.
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Сиквелы',
               Anime.where(id: [477,861,793,16,71,73,3667,5355,6213,4654,1519,889,2159,5342]).
                     where { id.not_in Anime::EXCLUDED_ONGOINGS }.
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Фильмы этого года',
               Anime.where(AniMangaSeason.query_for(DateTime.now.year.to_s)).
                     where { id.not_in Anime::EXCLUDED_ONGOINGS }.
                     where { id.not_in my{goals_ids} }.
                     #where { id.not_in [13409, 14093] }.
                     where { score.gte(7.5) | status.eq(AniMangaStatus::Anons) }.
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     where(kind: 'Movie').
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(45)]

    @goals << ['Зима 2014',
               Anime.where(AniMangaSeason.query_for('winter_2014')).
                     where { id.not_in my{goals_ids} }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     limit(30)]
    @goals << ['Осень 2013',
               Anime.where(AniMangaSeason.query_for('fall_2013')).
                     where { id.not_in my{goals_ids} }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     limit(30)]
    @goals << ['Лето 2013',
               Anime.where(AniMangaSeason.query_for('summer_2013')).
                     where { id.not_in my{goals_ids} }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     limit(30)]
    @goals << ['Весна 2013',
               Anime.where(AniMangaSeason.query_for('spring_2013')).
                     where { id.not_in my{goals_ids} }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     limit(30)]
    @goals << ['Зима 2013',
               Anime.where(AniMangaSeason.query_for('winter_2013')).
                     where { id.not_in my{goals_ids} }.
                     #where { id.not_in [13409, 14093] }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(30)]
    @goals << ['Осень 2012',
               Anime.where(AniMangaSeason.query_for('fall_2012')).
                     where { id.not_in my{goals_ids} }.
                     #where { id.not_in [13409, 14093] }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(30)]
    @goals << ['Лето 2012',
               Anime.where(AniMangaSeason.query_for('summer_2012')).
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in [13409, 14093] }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(40)]
    @goals << ['Весна 2012',
               Anime.where(AniMangaSeason.query_for('spring_2012')).
                     where { id.not_in my{goals_ids} }.
                     #where { id.not_in [11385] }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(30)]
    @goals << ['Зима 2012',
               Anime.where(AniMangaSeason.query_for('winter_2012')).
                     where { id.not_in my{goals_ids} }.
                     #where { id.not_in [11385] }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(30)]
    @goals << ['Осень 2011',
               Anime.where(AniMangaSeason.query_for('fall_2011')).
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in [11385] }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(30)]
    @goals << ['Лето 2011',
               Anime.where(AniMangaSeason.query_for('summer_2011')).
                     where { id.not_in my{goals_ids} }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(30)]
    @goals << ['Весна 2011',
               Anime.where(AniMangaSeason.query_for('spring_2011')).
                     where { id.not_in my{goals_ids} }.
                     where('score > 0 or ranked > 0').
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(25)]
    @goals << ['Весна 2010',
               Anime.where(AniMangaSeason.query_for('fall_2010')).
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where { ranked.not_eq 0 }.
                     where(censored: false).
                     order(:ranked).
                     limit(18)]
    @goals << ['Лето 2010',
               Anime.where(AniMangaSeason.query_for('summer_2010')).
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where { ranked.not_eq 0 }.
                     where(censored: false).
                     order(:ranked).
                     limit(10)]
    @goals << ['Весна 2010',
               Anime.where(AniMangaSeason.query_for('spring_2010')).
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where { ranked.not_eq 0 }.
                     where(censored: false).
                     order(:ranked).
                     limit(10)]
    @goals << ['Зима 2010',
               Anime.where(AniMangaSeason.query_for('winter_2010')).
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where { ranked.not_eq 0 }.
                     where(censored: false).
                     order(:ranked).
                     limit(9)]
    @goals << ['Весна 2009',
               Anime.where(AniMangaSeason.query_for('fall_2009')).
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where { ranked.not_eq 0 }.
                     where(censored: false).
                     order(:ranked).
                     limit(12)]
    @goals << ['Лето 2009',
               Anime.where(AniMangaSeason.query_for('summer_2009')).
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     translatable.
                     where { ranked.not_eq 0 }.
                     where(censored: false).
                     order(:ranked).
                     limit(12)]
    @goals << ['Фильмы прошлых лет',
               Anime.where(AniMangaSeason.query_for("#{DateTime.now.year-3}_#{DateTime.now.year-1}")).
                     where { id.not_in Anime::EXCLUDED_ONGOINGS }.
                     where { id.not_in my{goals_ids} }.
                     #where { id.not_in [13409, 14093] }.
                     where { score.gte 7.5 }.
                     where('duration is null or duration = 0 or duration > 20').
                     where { id.not_in my{@translate_ignore} }.
                     where(kind: 'Movie').
                     where(censored: false).
                     order(:ranked).
                     #order(:score.desc).
                     limit(45)]
    @goals << ['В избранном у пользователей',
               Anime.where(id: Favourite.where(linked_type: Anime.name).group(:linked_id).order('count(*) desc').limit(300).map(&:linked_id)).
                     where { id.not_in my{goals_ids} }.
                     where { kind.not_in ['Special', 'Music'] }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка фильмов',
               Anime.where(id: [5310,7222,1034,1824,1379,2594,6637,1089,9760,464,6372,570,974,8247,885,3089,597,31,3087,441,867,713,743,462,869,866,868,867,536,2889,6162,463,1192,4835,493,1686,465,2472,459,522,1815,442,460,461,155,4970,8246,4437,405,4246,2811,1829,936,9000,8115]).
                     where { id.not_in my{goals_ids} }.
                     order(:ranked)]
    @goals << ['Подборка 9',
               Anime.where(id: [1576,5734,5702]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка 8',
               Anime.where(id: [411,3701,1065,232,1485,85,3604,2112,407,1293,210,2829,4087,1808,3420,1483,880,455,323,1412,586,129,1454,593,364,2835,166,1852,2216,2409,1878,489,181,1589,11235,131,147,710,852,1250,5233,5984,798,1858,130,2204,696,1006,539,538,1147,541,540,1146,5504,1067,2460,1846,845,5675,4483,390,94,6758,173,1860,411,92,238,3322,1546,274,107,872,144,5041,52,2030,1397,3363,1576,2369,1086,3614,1602,2543,696,538,1133,539,5675,5420]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка 7',
               Anime.where(id: [3091,7711,1974,338,721,1914,1453,18,1486,395,384,9181,9617,123,872,306,133,32,5671,593,4087,166,5039,1860,2216,8937,4028,586,2594,634,3420,5005,3001,114,587,156,1690,4087,800,277,1592,2403,5060,11759,2162,417,4657,207]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка 6',
               Anime.where(id: [590,4719,4550,2924,6811,2508,106,5835,145,5958,4186,5150,200,2927,1965,3673,2012,940,3229,50,5597,4879,483,1013,341,198,4884,3467,195,3298,178,7088,1555,325,5079,3125,857,3927,2581,392,77,4192,967,1088,6046,5485,93,65,1719,1915,5074,132,67,26,389,209,165,2002,134,95,4038,3613,25,20,709,154,113,4581,5034,2683,953,878,5226,935,763,573,3731,334,68,4789]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка 5',
               Anime.where(id: [1498,3457,4752,150,270,27,1726,777,180,239,236,257,182,534,1164,1017,1045,3230,167,174,30,3588,329]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка 4',
               Anime.where(id: [1555,189,79,2476,4999,53,62,120,2993,248,3455,4214,3627,2595,291,4744,471,1222,846,4262,4063,259,177,969,569,251,1699,322,6201]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка 3',
               Anime.where(id: [43,387,227,1462,534,543,1002,6610,6164,4903,416,1172,535,2130,1738,1292,512,572,101,2787,5040,5682,6,2963,3225,5162,5713,256,47,237,856,169,153,59,2985,61,6676,343,33,3002,135,790,379,3594,5507,5525,1536,949]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка 2',
               Anime.where(id: [24,2104,355,1691,356,4654,1195,1840,3712,469,66,1887,2605,3228,6377,2104,158,3470,1579,2129,490,2986,1519,889,3572,1818,267,4725,400,2026,97,202,4106,1594,3713,228,98,99,76,7059,30,226,64,1827,2596]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Подборка 1',
               Anime.where(id: AniMangaQuery::AnimeFeatured).
                     where { id.not_in Anime::EXCLUDED_ONGOINGS }.
                     where { id.not_in my{goals_ids} }.
                     where { id.not_in my{@translate_ignore} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Ai',
               Anime.where(id: [2238,149,553,3210,243,719,1020,3375,3656,1532,850,3750,1729,444,98,879,4535,1569,6203,143]).
                     where { id.not_in my{goals_ids} }.
                     where(censored: false).
                     order(:ranked)]
    @goals << ['Kara no Kyoukai',
               Anime.where { name.like '%Kara no K%' }.
                     where(censored: false).
                     order(:name)]
    @goals << ['Ghost in the Shell',
               Anime.where { name.like '%Ghost in the S%' }.
                     where { id.not_in my{@translate_ignore} }.
                     where { id.lt 10000 }.
                     where(censored: false).
                     order(:name)]
    @goals << ['Break Blade',
               Anime.where { name.like '%Break Bla%' }.
                     where { id.not_in my{@translate_ignore} }.
                     where(censored: false).
                     order(:name)]
    @goals << ['Miyazaki Hayao',
               Person.find(1870).animes.
                      where('animes.id not in (?)', Anime::EXCLUDED_ONGOINGS).
                      where('animes.id not in (?)', @translate_ignore).
                      where('animes.kind != ?', 'Music').
                      where(censored: false).
                      order(:ranked).
                      limit(10)]
  end

  def planned
    @group ||= Group.find(params[:id])
    @page_title = [@group.name, 'Запланированные переводы']
    index
    @goals.each_with_index do |v,k|
      v[1] = v[1].select {|anime| anime.description == nil || anime.description == '' || anime.description == anime.description_mal }
    end
    @locks = TranslationController.locked_animes
    @changes = TranslationController.pending_animes
    @goals = @goals.select {|k,v| !v.empty? }
    show
  end

  def finished
    @group ||= Group.find(params[:id])
    @page_title = [@group.name, 'Завершённые переводы']
    index
    @goals.each_with_index do |v,k|
      v[1] = v[1].select {|anime| !(anime.description == nil || anime.description == '' || anime.description == anime.description_mal) }
    end
    @translates = TranslationController.accepted_animes
    show
  end

  # хеш с залоченными аниме
  def self.locked_animes
    UserChange.where(status: UserChangeStatus::Locked)
              .where(model: 'anime')
              .all
                .each_with_object({}) {|v,memo| memo[v.item_id] = v }
  end

  # хеш со ждущими модерации аниме
  def self.pending_animes
    UserChange.where(status: UserChangeStatus::Pending)
              .where(model: 'anime')
              .includes(:user)
              .all
                .each_with_object({}) {|v,memo| memo[v.item_id] = v }
  end

  # хеш с принятыми аниме
  def self.accepted_animes
    UserChange.where(status: UserChangeStatus::Accepted)
              .where(model: 'anime')
              .includes(:user)
              .all
                .each_with_object({}) {|v,memo| memo[v.item_id] = v }
  end

  def goals_ids
    @goals.map {|k,v| v.map(&:id) }.flatten
  end
end
