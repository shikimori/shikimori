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
        mystery
        police
        space
        sports

        music
      ],
      # rubocop:disable Layout/LineLength, Metrics/CollectionLiteralLength
      NekoGroup[:franchise] => %i[
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto demon_slayer konosuba re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai evangelion code_geass ao_no_exorcist overlord mob_psycho ansatsu_kyoushitsu jojo_no_kimyou_na_bouken bungou_stray_dogs hunter_x_hunter danmachi kaguya_sama haikyuu tensei_shitara_slime_datta_ken mushoku_tensei dr_stone yahari_ore_no_seishun_love_comedy_wa_machigatteiru kuroko_no_basket bleach psycho_pass fairy_tail bakemonogatari fate berserk shokugeki_no_souma kamisama_hajimemashita chuunibyou_demo_koi_ga_shitai high_school_dxd kuroshitsuji hellsing danganronpa durarara darker_than_black black_clover mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on one_piece mahoyome black_lagoon date_a_live quanzhi_gaoshou when_they_cry saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima toaru_majutsu_no_index k magi bakuman puella_magi_sonico_magica grisaia devilman gintama ore_no_imouto clannad free strike_the_blood to_love_ru mo_dao_zu_shi shingeki_no_bahamut natsume_yuujinchou mushishi full_metal_panic fruits_basket xian_wang_de_richang_shenghuo kami_nomi_zo_shiru_sekai baki kara_no_kyoukai rurouni_kenshin sora_no_otoshimono seitokai_yakuindomo blood tales_of initial_d golden_kamuy love_live non_non_biyori ashita_no_joe quanzhi_fashi sailor_moon junjou_romantica pokemon karakai_jouzu_no_takagi_san honzuki_no_gekokujou working baka_to_test_to_shoukanjuu arslan_senki ushio_to_tora jigoku_shoujo uta_no_prince_sama shakugan_no_shana hibike_euphonium hajime_no_ippo xxxholic persona rozen_maiden sayonara_zetsubou_sensei amagami_ss chihayafuru negima gundam dragon_ball hakuouki hoozuki_no_reitetsu baku_tech_bakugan yuru_yuri yi_ren_zhi_xia tenchi_muyou lupin_iii terra_formars yowamushi_pedal hetalia garo nodame_cantabile inuyasha utawarerumono detective_conan ginga_eiyuu_densetsu macross gochuumon_wa_usagi_desu_ka little_busters kingdom ginga_tetsudou eureka_seven slayers schwarzesmarken dog_days brave_witches diamond_no_ace selector_spread_wixoss tiger_bunny sonic ikkitousen osomatsu_san slam_dunk minami_ke yozakura_quartet koneko_no_chi tsubasa black_jack aa_megami_sama cardcaptor_sakura genshiken school_rumble zhen_hun_jie jashin_chan_dropkick uma_musume hayate_no_gotoku aggressive_retsuko idolmaster sengoku_basara touken_ranbu tennis_no_ouji_sama urusei_yatsura kiniro_no_corda gatchaman aquarion hack major teekyuu inazuma_eleven doupo_cangqiong yuu_yuu_hakusho hokuto_no_ken uchuu_senkan_yamato majutsushi_orphen bastard atom aria bang_dream puso_ni_comi idolish7 yu_gi_oh mahou_shoujo_lyrical_nanoha show_by_rock huyao_xiao_hongniang yao_shen_ji toriko uchuu_kyoudai queen_s_blade mobile_police_patlabor cardfight_vanguard senki_zesshou_symphogear marvel binan_koukou_chikyuu_boueibu_love yuki_yuna_is_a_hero guyver fushigi_yuugi saint_seiya ookiku_furikabutte digimon muumin saiyuki yama_no_susume city_hunter beyblade ad_police pretty_cure ranma taiho_shichau_zo mai_hime maria_sama starmyu soukyuu_no_fafner saki seikai_no_senki aikatsu lodoss_tou_senki glass_no_kamen angelique stitch d_c xingchen_bian danball_senki tsukipro_the_animation gegege_no_kitarou tamayura hidamari_sketch pripara ze_tian_ji kimagure_orange_road wan_jie_xian_zong a_mortal_s_journey street_fighter_ii harukanaru_toki_no_naka_de sakura_taisen cutey_honey ojamajo_doremi koihime_musou wu_geng_ji kindaichi_shounen_no_jikenbo votoms_finder touch futari_wa_milky_holmes space_cobra transformers captain_tsubasa cyborg dirty_pair ling_yu to_heart el_hazard xia_lan time_bokan di_gi_charat ultraman konjiki_no_gash_bell jewelpet jigoku_sensei_nube mazinkaiser dragon_quest saber_marionette_j jungle_taitei shaonian_ge_xing getter_robo galaxy_angel yoligongju_loopy xi_xing_ji haou_daikei_ryuu_knight
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
