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
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto demon_slayer konosuba re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai evangelion code_geass overlord ao_no_exorcist mob_psycho ansatsu_kyoushitsu jojo_no_kimyou_na_bouken bungou_stray_dogs hunter_x_hunter danmachi kaguya_sama haikyuu tensei_shitara_slime_datta_ken mushoku_tensei yahari_ore_no_seishun_love_comedy_wa_machigatteiru dr_stone kuroko_no_basket bleach psycho_pass fairy_tail bakemonogatari fate shokugeki_no_souma berserk chuunibyou_demo_koi_ga_shitai kamisama_hajimemashita high_school_dxd kuroshitsuji hellsing danganronpa durarara darker_than_black black_clover mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on one_piece mahoyome black_lagoon date_a_live quanzhi_gaoshou when_they_cry saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima toaru_majutsu_no_index k magi bakuman puella_magi_sonico_magica grisaia gintama devilman ore_no_imouto clannad free strike_the_blood to_love_ru mo_dao_zu_shi shingeki_no_bahamut natsume_yuujinchou mushishi full_metal_panic fruits_basket kami_nomi_zo_shiru_sekai baki kara_no_kyoukai sora_no_otoshimono seitokai_yakuindomo rurouni_kenshin blood tales_of love_live initial_d golden_kamuy non_non_biyori ashita_no_joe quanzhi_fashi sailor_moon junjou_romantica pokemon karakai_jouzu_no_takagi_san working honzuki_no_gekokujou baka_to_test_to_shoukanjuu arslan_senki ushio_to_tora jigoku_shoujo uta_no_prince_sama shakugan_no_shana hibike_euphonium hajime_no_ippo xxxholic persona rozen_maiden sayonara_zetsubou_sensei amagami_ss chihayafuru negima gundam dragon_ball hakuouki hoozuki_no_reitetsu baku_tech_bakugan yuru_yuri yi_ren_zhi_xia tenchi_muyou lupin_iii yowamushi_pedal terra_formars hetalia garo nodame_cantabile inuyasha utawarerumono detective_conan ginga_eiyuu_densetsu macross gochuumon_wa_usagi_desu_ka little_busters eureka_seven ginga_tetsudou kingdom slayers schwarzesmarken dog_days brave_witches selector_spread_wixoss diamond_no_ace tiger_bunny ikkitousen sonic osomatsu_san slam_dunk minami_ke yozakura_quartet koneko_no_chi tsubasa black_jack aa_megami_sama cardcaptor_sakura genshiken school_rumble zhen_hun_jie jashin_chan_dropkick uma_musume hayate_no_gotoku idolmaster aggressive_retsuko sengoku_basara touken_ranbu tennis_no_ouji_sama kiniro_no_corda urusei_yatsura gatchaman aquarion hack major teekyuu inazuma_eleven doupo_cangqiong yuu_yuu_hakusho hokuto_no_ken uchuu_senkan_yamato majutsushi_orphen bastard aria bang_dream puso_ni_comi idolish7 yu_gi_oh mahou_shoujo_lyrical_nanoha show_by_rock huyao_xiao_hongniang yao_shen_ji toriko atom uchuu_kyoudai queen_s_blade mobile_police_patlabor cardfight_vanguard senki_zesshou_symphogear marvel binan_koukou_chikyuu_boueibu_love yuki_yuna_is_a_hero guyver ookiku_furikabutte fushigi_yuugi saint_seiya digimon muumin saiyuki yama_no_susume beyblade pretty_cure ad_police city_hunter ranma taiho_shichau_zo mai_hime maria_sama starmyu soukyuu_no_fafner saki seikai_no_senki aikatsu glass_no_kamen angelique lodoss_tou_senki d_c stitch xingchen_bian tsukipro_the_animation danball_senki gegege_no_kitarou tamayura hidamari_sketch ze_tian_ji pripara kimagure_orange_road wan_jie_xian_zong a_mortal_s_journey street_fighter_ii harukanaru_toki_no_naka_de sakura_taisen cutey_honey ojamajo_doremi koihime_musou wu_geng_ji kindaichi_shounen_no_jikenbo votoms_finder touch futari_wa_milky_holmes space_cobra captain_tsubasa transformers cyborg dirty_pair ling_yu to_heart el_hazard xia_lan ultraman di_gi_charat time_bokan konjiki_no_gash_bell jewelpet mazinkaiser jigoku_sensei_nube dragon_quest saber_marionette_j jungle_taitei getter_robo shaonian_ge_xing galaxy_angel yoligongju_loopy haou_daikei_ryuu_knight
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
