module Types
  module Achievement
    NEKO_GROUPS = %i[common genre franchise author]
    NekoGroup = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_GROUPS)

    NEKO_IDS = {
      NekoGroup[:common] => %i[
        test

        animelist

        otaku
        fujoshi
        yuuri

        tsundere
        yandere
        kuudere
        moe
        genki
        gar
        oniichan
        longshounen
        shortie

        world_masterpiece_theater
        oldfag
        sovietanime
        stop_motion
      ],
      NekoGroup[:genre] => %i[
        comedy
        romance
        fantasy
        historical
        mahou_shoujo
        dementia_psychological
        mecha
        slice_of_life
        scifi
        supernatural

        drama
        horror_thriller
        josei
        kids
        military
        mystery
        police
        space
        sports

        music
      ],
      # rubocop:disable Layout/LineLength
      NekoGroup[:franchise] => %i[
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto re_zero boku_no_hero_academia demon_slayer fullmetal_alchemist science_adventure nanatsu_no_taizai ao_no_exorcist code_geass overlord ansatsu_kyoushitsu mob_psycho evangelion jojo_no_kimyou_na_bouken bungou_stray_dogs danmachi haikyuu yahari_ore_no_seishun_love_comedy_wa_machigatteiru fairy_tail tensei_shitara_slime_datta_ken psycho_pass kuroko_no_basket hunter_x_hunter bakemonogatari fate shokugeki_no_souma chuunibyou_demo_koi_ga_shitai bleach kuroshitsuji kamisama_hajimemashita high_school_dxd berserk durarara hellsing danganronpa darker_than_black mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on date_a_live black_clover quanzhi_gaoshou one_piece when_they_cry black_lagoon saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima k toaru_majutsu_no_index magi bakuman puella_magi_sonico_magica ore_no_imouto grisaia gintama clannad free strike_the_blood devilman to_love_ru shingeki_no_bahamut natsume_yuujinchou mushishi mo_dao_zu_shi full_metal_panic kami_nomi_zo_shiru_sekai sora_no_otoshimono tales_of kara_no_kyoukai seitokai_yakuindomo blood love_live fruits_basket junjou_romantica non_non_biyori rurouni_kenshin ashita_no_joe sailor_moon quanzhi_fashi working baka_to_test_to_shoukanjuu pokemon karakai_jouzu_no_takagi_san arslan_senki initial_d golden_kamuy ushio_to_tora baki uta_no_prince_sama jigoku_shoujo shakugan_no_shana honzuki_no_gekokujou rozen_maiden persona hibike_euphonium sayonara_zetsubou_sensei amagami_ss xxxholic chihayafuru hajime_no_ippo hakuouki negima hoozuki_no_reitetsu yuru_yuri dragon_ball baku_tech_bakugan tenchi_muyou hitori_no_shita hetalia gundam yowamushi_pedal garo terra_formars nodame_cantabile lupin_iii inuyasha utawarerumono detective_conan macross eureka_seven ginga_eiyuu_densetsu gochuumon_wa_usagi_desu_ka little_busters ginga_tetsudou slayers dog_days selector_spread_wixoss tiger_bunny brave_witches diamond_no_ace osomatsu_san ikkitousen yozakura_quartet tsubasa minami_ke black_jack koneko_no_chi aa_megami_sama genshiken school_rumble cardcaptor_sakura hayate_no_gotoku slam_dunk sengoku_basara idolmaster kiniro_no_corda gatchaman tennis_no_ouji_sama aquarion hack major teekyuu douluo_dalu hokuto_no_ken inazuma_eleven puso_ni_comi uchuu_senkan_yamato yuu_yuu_hakusho aria majutsushi_orphen yu_gi_oh bang_dream huyao_xiao_hongniang mahou_shoujo_lyrical_nanoha idolish7 show_by_rock toriko yao_shen_ji uchuu_kyoudai binan_koukou_chikyuu_boueibu_love queen_s_blade senki_zesshou_symphogear cardfight_vanguard marvel doupo_cangqiong yuki_yuna_is_a_hero mobile_police_patlabor ookiku_furikabutte fushigi_yuugi saint_seiya guyver digimon saiyuki starmyu mai_hime ranma maria_sama pretty_cure city_hunter soukyuu_no_fafner beyblade saki ad_police taiho_shichau_zo angelique seikai_no_senki aikatsu glass_no_kamen d_c urusei_yatsura stitch gegege_no_kitarou pripara tamayura ze_tian_ji hidamari_sketch kimagure_orange_road xingchen_bian danball_senki harukanaru_toki_no_naka_de sakura_taisen wan_jie_xian_zong cutey_honey koihime_musou kindaichi_shounen_no_jikenbo futari_wa_milky_holmes votoms_finder captain_tsubasa space_cobra cyborg transformers ling_yu time_bokan dirty_pair konjiki_no_gash_bell el_hazard to_heart mazinkaiser jigoku_sensei_nube di_gi_charat saber_marionette_j galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada makoto_shinkai hayao_miyazaki hiroyuki_imaishi shinichiro_watanabe hiroshi_hamasaki key yasuhiro_takemoto akiyuki_shinbou takahiro_oomori gen_urobuchi hideaki_anno chiaki_kon mamoru_hosoda type_moon osamu_tezuka isao_takahata shoji_kawamori kouji_morimoto morio_asaka masaaki_yuasa satoshi_kon mamoru_oshii masamune_shirow shinji_aramaki kenji_kamiyama yoshiaki_kawajiri junichi_satou clamp go_nagai katsuhiro_otomo kenji_nakamura kouichi_mashimo kunihiko_ikuhara yoshitaka_amano osamu_dezaki rumiko_takahashi leiji_matsumoto rintaro yoshiyuki_tomino ryousuke_takahashi toshio_maeda
      ]
      # rubocop:enable Layout/LineLength
    }
    INVERTED_NEKO_IDS = NEKO_IDS.each_with_object({}) do |(group, ids), memo|
      ids.each { |id| memo[id] = NekoGroup[group] }
    end
    ORDERED_NEKO_IDS = INVERTED_NEKO_IDS.keys

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ORDERED_NEKO_IDS)
  end
end
