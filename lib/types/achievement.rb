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
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto re_zero demon_slayer boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai ao_no_exorcist code_geass overlord ansatsu_kyoushitsu evangelion mob_psycho jojo_no_kimyou_na_bouken bungou_stray_dogs danmachi haikyuu yahari_ore_no_seishun_love_comedy_wa_machigatteiru tensei_shitara_slime_datta_ken kaguya_sama hunter_x_hunter kuroko_no_basket psycho_pass fairy_tail bakemonogatari fate shokugeki_no_souma chuunibyou_demo_koi_ga_shitai bleach kuroshitsuji kamisama_hajimemashita high_school_dxd berserk hellsing durarara danganronpa darker_than_black mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on black_clover date_a_live one_piece quanzhi_gaoshou when_they_cry black_lagoon saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima k toaru_majutsu_no_index magi bakuman puella_magi_sonico_magica grisaia ore_no_imouto gintama clannad free strike_the_blood devilman to_love_ru shingeki_no_bahamut natsume_yuujinchou mo_dao_zu_shi mushishi full_metal_panic kami_nomi_zo_shiru_sekai sora_no_otoshimono tales_of kara_no_kyoukai seitokai_yakuindomo blood fruits_basket love_live non_non_biyori junjou_romantica rurouni_kenshin ashita_no_joe sailor_moon quanzhi_fashi working pokemon baka_to_test_to_shoukanjuu karakai_jouzu_no_takagi_san initial_d arslan_senki golden_kamuy baki ushio_to_tora uta_no_prince_sama jigoku_shoujo shakugan_no_shana honzuki_no_gekokujou hibike_euphonium rozen_maiden persona sayonara_zetsubou_sensei amagami_ss xxxholic chihayafuru hajime_no_ippo hakuouki negima hoozuki_no_reitetsu yuru_yuri dragon_ball baku_tech_bakugan hitori_no_shita tenchi_muyou hetalia gundam yowamushi_pedal terra_formars garo nodame_cantabile lupin_iii utawarerumono inuyasha detective_conan macross ginga_eiyuu_densetsu eureka_seven gochuumon_wa_usagi_desu_ka little_busters ginga_tetsudou slayers dog_days brave_witches selector_spread_wixoss tiger_bunny diamond_no_ace osomatsu_san ikkitousen yozakura_quartet tsubasa minami_ke black_jack koneko_no_chi aa_megami_sama genshiken cardcaptor_sakura school_rumble slam_dunk hayate_no_gotoku sengoku_basara idolmaster kiniro_no_corda gatchaman tennis_no_ouji_sama aquarion hack major teekyuu inazuma_eleven hokuto_no_ken uchuu_senkan_yamato puso_ni_comi yuu_yuu_hakusho aria majutsushi_orphen bang_dream yu_gi_oh idolish7 mahou_shoujo_lyrical_nanoha huyao_xiao_hongniang show_by_rock toriko yao_shen_ji uchuu_kyoudai queen_s_blade binan_koukou_chikyuu_boueibu_love senki_zesshou_symphogear doupo_cangqiong cardfight_vanguard marvel mobile_police_patlabor yuki_yuna_is_a_hero ookiku_furikabutte fushigi_yuugi saint_seiya guyver digimon saiyuki starmyu mai_hime ranma city_hunter maria_sama pretty_cure soukyuu_no_fafner beyblade ad_police taiho_shichau_zo saki angelique seikai_no_senki aikatsu glass_no_kamen d_c urusei_yatsura stitch gegege_no_kitarou pripara tamayura ze_tian_ji hidamari_sketch kimagure_orange_road danball_senki xingchen_bian harukanaru_toki_no_naka_de sakura_taisen wan_jie_xian_zong cutey_honey koihime_musou kindaichi_shounen_no_jikenbo futari_wa_milky_holmes votoms_finder captain_tsubasa cyborg space_cobra transformers ling_yu dirty_pair time_bokan el_hazard to_heart konjiki_no_gash_bell mazinkaiser di_gi_charat jigoku_sensei_nube saber_marionette_j galaxy_angel haou_daikei_ryuu_knight touch
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
