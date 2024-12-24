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
        detektiv
        space
        sports

        music
      ],
      # rubocop:disable Layout/LineLength, Metrics/CollectionLiteralLength
      NekoGroup[:franchise] => %i[
        shingeki_no_kyojin tokyo_ghoul one_punch_man demon_slayer sword_art_online naruto konosuba re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai evangelion mob_psycho code_geass overlord ao_no_exorcist ansatsu_kyoushitsu jojo_no_kimyou_na_bouken mushoku_tensei hunter_x_hunter bungou_stray_dogs tensei_shitara_slime_datta_ken kaguya_sama danmachi haikyuu dr_stone yahari_ore_no_seishun_love_comedy_wa_machigatteiru bleach kuroko_no_basket psycho_pass berserk ookami_to_koushinryou fairy_tail bakemonogatari fate shokugeki_no_souma kamisama_hajimemashita chuunibyou_demo_koi_ga_shitai high_school_dxd kuroshitsuji hellsing danganronpa durarara black_clover one_piece darker_than_black mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on mahoyome black_lagoon quanzhi_gaoshou date_a_live when_they_cry saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima toaru_majutsu_no_index magi k bakuman puella_magi_sonico_magica devilman grisaia gintama clannad kimi_ni_todoke ore_no_imouto free strike_the_blood mo_dao_zu_shi to_love_ru shingeki_no_bahamut natsume_yuujinchou xian_wang_de_richang_shenghuo fruits_basket mushishi baki full_metal_panic kami_nomi_zo_shiru_sekai rurouni_kenshin kara_no_kyoukai blood seitokai_yakuindomo initial_d sora_no_otoshimono golden_kamuy tales_of quanzhi_fashi non_non_biyori ashita_no_joe love_live sailor_moon honzuki_no_gekokujou junjou_romantica pokemon karakai_jouzu_no_takagi_san working baka_to_test_to_shoukanjuu arslan_senki ushio_to_tora jigoku_shoujo hibike_euphonium hajime_no_ippo uta_no_prince_sama shakugan_no_shana xxxholic persona rozen_maiden sayonara_zetsubou_sensei amagami_ss chihayafuru dragon_ball gundam negima hoozuki_no_reitetsu hakuouki baku_tech_bakugan yuru_yuri yi_ren_zhi_xia lupin_iii tenchi_muyou terra_formars yowamushi_pedal hetalia garo nodame_cantabile ginga_eiyuu_densetsu inuyasha utawarerumono detective_conan kingdom macross gochuumon_wa_usagi_desu_ka little_busters ginga_tetsudou slayers eureka_seven schwarzesmarken dog_days brave_witches diamond_no_ace kengan_ashura selector_spread_wixoss sonic tiger_bunny ikkitousen slam_dunk osomatsu_san soul_land atom minami_ke cardcaptor_sakura koneko_no_chi genshiken yozakura_quartet black_jack tsubasa aa_megami_sama jashin_chan_dropkick school_rumble zhen_hun_jie uma_musume urusei_yatsura aggressive_retsuko hayate_no_gotoku idolmaster sengoku_basara touken_ranbu tennis_no_ouji_sama doupo_cangqiong kiniro_no_corda gatchaman inazuma_eleven aquarion hack major teekyuu yuu_yuu_hakusho bastard hokuto_no_ken aria uchuu_senkan_yamato majutsushi_orphen bang_dream idolish7 puso_ni_comi yu_gi_oh mahou_shoujo_lyrical_nanoha show_by_rock yao_shen_ji huyao_xiao_hongniang ranma toriko uchuu_kyoudai mobile_police_patlabor queen_s_blade cardfight_vanguard marvel senki_zesshou_symphogear binan_koukou_chikyuu_boueibu_love yuki_yuna_is_a_hero guyver saint_seiya fushigi_yuugi ookiku_furikabutte muumin digimon beyblade yama_no_susume city_hunter saiyuki ad_police pretty_cure taiho_shichau_zo mai_hime maria_sama soukyuu_no_fafner starmyu lodoss_tou_senki saki seikai_no_senki swallowed_star glass_no_kamen bai_yao_pu aikatsu stitch angelique d_c xingchen_bian danball_senki a_mortal_s_journey gegege_no_kitarou tsukipro_the_animation tamayura hidamari_sketch pripara ze_tian_ji kimagure_orange_road wan_jie_xian_zong beryl_and_sapphire ojamajo_doremi kaleido_star street_fighter_ii cutey_honey harukanaru_toki_no_naka_de sakura_taisen wu_geng_ji koihime_musou kindaichi_shounen_no_jikenbo votoms_finder futari_wa_milky_holmes touch space_cobra transformers captain_tsubasa cyborg dirty_pair xue_ying_ling_zhu ling_yu to_heart jewelpet di_gi_charat xia_lan el_hazard time_bokan ultraman konjiki_no_gash_bell jigoku_sensei_nube mazinkaiser jungle_taitei dragon_quest saber_marionette_j shaonian_ge_xing betterman getter_robo galaxy_angel yoligongju_loopy jiu_tian_xuan_di_jue xi_xing_ji hello_kitty fantastica haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki makoto_shinkai hayao_miyazaki mari_okada tensai_okamura shinichiro_watanabe hiroyuki_imaishi key hiroshi_hamasaki yasuhiro_takemoto gen_urobuchi akiyuki_shinbou takahiro_oomori chiaki_kon hideaki_anno mamoru_hosoda osamu_tezuka isao_takahata type_moon shoji_kawamori morio_asaka masaaki_yuasa satoshi_kon mamoru_oshii masamune_shirow shinji_aramaki kenji_kamiyama junichi_satou clamp go_nagai katsuhiro_otomo yoshiaki_kawajiri kenji_nakamura yoshitaka_amano kouichi_mashimo kunihiko_ikuhara kouji_morimoto osamu_dezaki rumiko_takahashi leiji_matsumoto yoshiyuki_tomino rintaro ryousuke_takahashi toshio_maeda
      ]
      # rubocop:enable Layout/LineLength, Metrics/CollectionLiteralLength
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
