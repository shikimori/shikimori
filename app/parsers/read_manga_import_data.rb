module ReadMangaImportData
  FullDescription = Set.new %w{
    yasashii_te
    jyun_ai_bride
    voices_in_the_dark
    inu_jikan
    a_relation_is_still_a_lv_1
    sweet_16
    kareki_ni_koi_wo_sakasemasu
    kneel_down_and_vow_your_love
    he_is_pretending_to_be_cold_attitude
    becoming_the_adult
    age_17
    princess_princess_premium
    suki_ni_naru_hito
    donut_letter
    gokujou_twins
    akutou_ii
    koko_niiru_sui_ren
    the_bus_takes_you_and_runs
    sos
    chat_noir_no_shippo
    honey_moon
    caramel_milk_tea
    paradise
    pure_love_stories
    true_tenderness
    brothers_of_japan
    shirahime_syo
    soaked_by_the_sun
    secretly_a_woman
    white_clouds
    sickness_of_the_first_love
    prince_in_love
    welcome_to_room__305
    smooth_over_his_hurt_feelings
    i_am_not_your_boyfriend
    tiger___bunny_dj___untitled
    tiger___bunny_dj___facet
    capable_young_man
    drifting_and_whirling
    if_you_leave_me
    doctor_mephistopheles
    konnichiwa__konekochan
    katekyo_hitman_reborn__dj___class_in_the_nurse_s_office
    lamento_dj___magnolia
    lover_s_name
    bitankan_extract
    the_deed_behind_the_ring_finger
    reversal_of_love_talk
    kuroshitsuji_dj___ice_coffin
    devil_may_cry_3_doujinshi__devil_s_confession_seeped_in_blood
    kuroshitsuji_dj___dolce_vita
  }

  NoDescription = Set.new %w{
    i_don_t_dislike_you
    moonlight_garden
    the_lover_for_10_000_yen
    system_of_romance
    deep_love__reina_s_fate
    hana_ni_kedamono
    darren_shan
    gto__shonan_14_days
    isn_t_it_love
    sakura_blooming_spring
    you_and_i_of_the_revolving_world
    darling
    7_days_of_week
    animal_jungle
    sickness_of_the_first_love
    katekyo_hitman_reborn__dj___lewd_culture_festival
    sengoku_basara__dj___dum_spiro__spero
    wolf_guy___wolfen_crest
    animal_jungle
    7_days_of_week
    tamate_note__shirahama_kouta_doujin_sakuhinshuu_vol_2
    the_enigma_of_amigara_fault
    brothers_of_japan
    zetman_katsura_masakazu_short_stories
    death_note
    crepuscule__yamchi
    same_cell_organism
    tabetai_hito
    halfway
    himeyuka___rozione_s_story
    sorcerous_stabber_orphen
    katekyo_hitman_reborn_dj___katekyo_hitman_reborn_dj___to_catch_you_all_da
    taiyou_no_ijiwaru
    harry_potter_dj___love_songs
    love_rental
  }

  MangaTeams = {
    'goldenwind.org' => 'http://goldenwind.ucoz.org',
    'crazy paradise' => 'http://www.diary.ru/~crazy-paradise',
    'world art' => 'http://world-art.ru',
    'death note - kira revival project' => 'http://deathnote.ru',
    'moonlight team' => 'http://moonlight-team.ru',
    'manga-kya' => 'http://manga-kya.ucoz.ru',
    'kukuruka team' => 'http://kukurukateam.ucoz.ru',
    'flower rain' => 'http://flower-rain.ucoz.ru',
    'flowerrain' => 'http://flower-rain.ucoz.ru',
    'action manga team' => 'http://actionmanga.ru',
    'kanablog' => 'http://kanablog.clan.su',
    'sweet stories' => 'http://ryazan.beon.ru',
    'cookie fly!' => 'http://cookiefly.ucoz.ru',
    'anigai-clan' => 'http://anigai-clan.ucoz.ru',
    'gentle world' => 'http://gentleworld.at.ua',
    'maid latte' => 'http://maidlatte.ucoz.ru',
    'animaxa' => 'http://animaxa.org',
    'golden wind' =>  'http://goldenwind.ucoz.org',
    'animanga' =>  'http://animanga.ru',
    'danjo scans' => 'http://danjo-scans.ru',
    'chouneko' => 'http://chouneko.net',
    'call of the wind' => 'http://callofthewind.net',
    'codeartstudio' => 'http://codeartstudio.org',
    'codeartstudiio' => 'http://codeartstudio.org',
    'soarin project' => 'http://soarin.ucoz.ru',
    'amica -manga' => 'http://amica-manga.net',
    'amica-manga' => 'http://amica-manga.net',
    'mangaman' => 'http://mangaman.ru',
    'black winged angels nest' => 'http://bwanest.narod.ru',
    'laboratory of dreams' => 'http://dreams.anilab.ru',
    'kusosekai manga' => 'http://kusosekai.info',
    'colorless manga' => 'http:/colorless-manga.su',
    'colorness manga' => 'http:/colorless-manga.su',
    'colerless manga' => 'http:/colorless-manga.su',
    'colerness manga' => 'http:/colorless-manga.su',
    'nomad team' => 'http://nomad.xost.me',
    'berserk world' => 'http://berserkworld.org',
    'aragamifansubgroup' => 'http://www.aragami-fansubs.ru',
    'cruelmanga' => 'http://cruelmanga.mangascans.net',
    'moonlight team' => 'http://moonlight-team.ru',
    'espada clan' => 'http://espadaclan.ru'
  }

  Translators = Set.new [
    'colour_palette',
    'shinigami',
    'kair',
    'miracle',
    'victoryday',
    'kanamushkao_o',
    'lory-chan',
    'lory-san',
    'all blue',
    'eva-chan',
    'tafira',
    'colorness manga',
    'd.t.',
    'baka team',
    'sneshanna',
    'south wind',
    'dense forest'
  ]

  CustomLinks = {
      nausicaa_of_the_valley_of_wind: 651,
      yotsuba: 104,
      obaku_hakairoku_kaiji: 3572,
      kino_s_journey__the_beautiful_world: 399,
      when_they_cry_2__eye_opening_chapter: 1262,
      when_cicadas_cry__curse_killing_chapter: 1260,
      when_cicadas_cry__floating_cotton_chapter: 1258,
      when_they_cry_2___demon_exposing_chapter: 1264,
      when_they_cry__time_killing_chapter: 1261,
      when_they_cry_overnight_chapter: 1265,
      merupuri__the_marchen_prince: 665,
      full_metal_panic__sigma: 895,
      full_metal_panic: 789,
      the_breaker__new_waves: 22651,
      the_world_s_best_first_love: 10573,
      totally_captivated_dj___last_episode: 19749,
      isn_t_it_love: 17890,
      alive: 965,
      wolf_guy___wolfen_crest: 12451,
      doubt: 5293,
      monochrome_mysterious_story: 14850,
      kiben_gakuha__yotsuya_senpai_no_kaidan: 19167,
      nana: 28,
      apple1: 11764,
      get_backers: 19,
      shaman_king: 50,
      shaman_king__flowers: 16572,
      monster: 1,
      boundary_of_emptiness: 23947,
      dance_in_the_vampire_bund: 7627,
      treat_me_gently: 1964,
      dear: 20704,
      neon_genesis_evangelion: 698,
      burning_love: 1978,
      the_vagrant_soldier_ares: 1076,
      nephilim: 11628,
      well__let_s_begin: 5860,
      ibitsu: 16688,
      the_center_of_the_hair_whorl: 5360,
      spring_fever: 226,
      rakuen__fujiwara_kaoru: 495,
      you_and_me__etc: 9643,
      reversal_of_love_talk: 14055,
      masked_teacher: 6853,
      basilisk__the_koga_ninja_scrolls: 221,
      i_can_t_stand_only_the_kiss: 2678,
      adultness: 4324,
      bus_gamer: 162,
      forget_me_not: 3780,
      the_irregular_at_magic_high_school: 33699,
      dogs__hardcore_twins: -1,
      the_lord_of_the_rings_dj___touch: -1,
      naruto_doujinshi__sakura: -1,
      paradise: -1,
      blue: -1,
      code_geass_dj___rainy_day: -1,
      virgin_blooms_at_night: -1,
      just_the_two_of_us: -1,
      open_sesame: 730,
      #katekyo_hitman_reborn__dj___sanctuary: -1
    }.inject({}) {|rez,v| rez[v[0].to_s] = v[1] and rez }
end
