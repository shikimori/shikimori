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
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto demon_slayer konosuba re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai evangelion overlord code_geass mob_psycho ao_no_exorcist ansatsu_kyoushitsu jojo_no_kimyou_na_bouken bungou_stray_dogs hunter_x_hunter mushoku_tensei kaguya_sama danmachi tensei_shitara_slime_datta_ken haikyuu dr_stone yahari_ore_no_seishun_love_comedy_wa_machigatteiru kuroko_no_basket bleach psycho_pass fairy_tail bakemonogatari berserk fate shokugeki_no_souma kamisama_hajimemashita chuunibyou_demo_koi_ga_shitai high_school_dxd kuroshitsuji hellsing danganronpa durarara darker_than_black black_clover mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on one_piece mahoyome black_lagoon date_a_live quanzhi_gaoshou when_they_cry saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima toaru_majutsu_no_index k magi bakuman puella_magi_sonico_magica grisaia devilman gintama clannad ore_no_imouto free strike_the_blood to_love_ru mo_dao_zu_shi shingeki_no_bahamut natsume_yuujinchou mushishi xian_wang_de_richang_shenghuo fruits_basket full_metal_panic kami_nomi_zo_shiru_sekai baki kara_no_kyoukai rurouni_kenshin seitokai_yakuindomo sora_no_otoshimono blood tales_of initial_d golden_kamuy love_live non_non_biyori quanzhi_fashi ashita_no_joe sailor_moon junjou_romantica pokemon karakai_jouzu_no_takagi_san honzuki_no_gekokujou working baka_to_test_to_shoukanjuu arslan_senki ushio_to_tora jigoku_shoujo uta_no_prince_sama hibike_euphonium shakugan_no_shana hajime_no_ippo xxxholic persona rozen_maiden sayonara_zetsubou_sensei amagami_ss chihayafuru gundam negima dragon_ball hakuouki hoozuki_no_reitetsu baku_tech_bakugan yuru_yuri yi_ren_zhi_xia tenchi_muyou lupin_iii terra_formars yowamushi_pedal hetalia garo nodame_cantabile inuyasha utawarerumono detective_conan ginga_eiyuu_densetsu macross kingdom gochuumon_wa_usagi_desu_ka little_busters ginga_tetsudou eureka_seven slayers schwarzesmarken dog_days brave_witches diamond_no_ace selector_spread_wixoss tiger_bunny sonic ikkitousen osomatsu_san slam_dunk minami_ke koneko_no_chi yozakura_quartet tsubasa black_jack cardcaptor_sakura aa_megami_sama genshiken school_rumble zhen_hun_jie jashin_chan_dropkick uma_musume hayate_no_gotoku aggressive_retsuko idolmaster urusei_yatsura sengoku_basara atom touken_ranbu tennis_no_ouji_sama kiniro_no_corda gatchaman aquarion hack major doupo_cangqiong inazuma_eleven teekyuu yuu_yuu_hakusho hokuto_no_ken bastard aria uchuu_senkan_yamato majutsushi_orphen bang_dream idolish7 puso_ni_comi yu_gi_oh mahou_shoujo_lyrical_nanoha show_by_rock huyao_xiao_hongniang yao_shen_ji toriko uchuu_kyoudai mobile_police_patlabor queen_s_blade cardfight_vanguard senki_zesshou_symphogear marvel binan_koukou_chikyuu_boueibu_love yuki_yuna_is_a_hero guyver fushigi_yuugi saint_seiya ookiku_furikabutte digimon muumin yama_no_susume saiyuki city_hunter beyblade pretty_cure ad_police taiho_shichau_zo ranma mai_hime maria_sama starmyu soukyuu_no_fafner saki seikai_no_senki lodoss_tou_senki aikatsu glass_no_kamen angelique stitch d_c xingchen_bian danball_senki tsukipro_the_animation gegege_no_kitarou tamayura hidamari_sketch pripara ze_tian_ji a_mortal_s_journey kimagure_orange_road wan_jie_xian_zong ojamajo_doremi street_fighter_ii cutey_honey harukanaru_toki_no_naka_de sakura_taisen koihime_musou wu_geng_ji kindaichi_shounen_no_jikenbo votoms_finder touch futari_wa_milky_holmes space_cobra transformers captain_tsubasa cyborg dirty_pair ling_yu jewelpet to_heart el_hazard xia_lan time_bokan di_gi_charat ultraman konjiki_no_gash_bell jigoku_sensei_nube mazinkaiser dragon_quest saber_marionette_j jungle_taitei shaonian_ge_xing getter_robo galaxy_angel yoligongju_loopy xi_xing_ji haou_daikei_ryuu_knight hello_kitty betterman fantastica beryl_and_sapphire jiu_tian_xuan_di_jue bai_yao_pu
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
