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
      # rubocop:disable Layout/LineLength, Metrics/CollectionLiteralLength
      NekoGroup[:franchise] => %i[
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto demon_slayer konosuba re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai ao_no_exorcist overlord code_geass evangelion mob_psycho ansatsu_kyoushitsu jojo_no_kimyou_na_bouken bungou_stray_dogs hunter_x_hunter danmachi kaguya_sama haikyuu tensei_shitara_slime_datta_ken yahari_ore_no_seishun_love_comedy_wa_machigatteiru mushoku_tensei dr_stone kuroko_no_basket psycho_pass bleach fairy_tail bakemonogatari fate shokugeki_no_souma chuunibyou_demo_koi_ga_shitai berserk kamisama_hajimemashita high_school_dxd kuroshitsuji hellsing danganronpa durarara darker_than_black mahouka_koukou_no_rettousei black_clover k_on suzumiya_haruhi_no_yuuutsu one_piece mahoyome black_lagoon date_a_live quanzhi_gaoshou when_they_cry saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima toaru_majutsu_no_index k magi bakuman puella_magi_sonico_magica grisaia gintama devilman ore_no_imouto clannad free strike_the_blood to_love_ru mo_dao_zu_shi shingeki_no_bahamut natsume_yuujinchou mushishi full_metal_panic fruits_basket kami_nomi_zo_shiru_sekai baki kara_no_kyoukai sora_no_otoshimono seitokai_yakuindomo rurouni_kenshin blood tales_of love_live golden_kamuy non_non_biyori initial_d ashita_no_joe quanzhi_fashi junjou_romantica sailor_moon pokemon karakai_jouzu_no_takagi_san working baka_to_test_to_shoukanjuu honzuki_no_gekokujou arslan_senki ushio_to_tora jigoku_shoujo uta_no_prince_sama shakugan_no_shana hibike_euphonium hajime_no_ippo xxxholic persona rozen_maiden sayonara_zetsubou_sensei amagami_ss chihayafuru negima gundam hakuouki dragon_ball hoozuki_no_reitetsu baku_tech_bakugan yuru_yuri yi_ren_zhi_xia tenchi_muyou lupin_iii yowamushi_pedal hetalia terra_formars garo nodame_cantabile utawarerumono inuyasha detective_conan ginga_eiyuu_densetsu macross gochuumon_wa_usagi_desu_ka little_busters eureka_seven ginga_tetsudou kingdom slayers schwarzesmarken dog_days brave_witches selector_spread_wixoss diamond_no_ace tiger_bunny ikkitousen osomatsu_san slam_dunk yozakura_quartet minami_ke koneko_no_chi tsubasa black_jack aa_megami_sama cardcaptor_sakura genshiken school_rumble jashin_chan_dropkick uma_musume hayate_no_gotoku idolmaster aggressive_retsuko sengoku_basara touken_ranbu tennis_no_ouji_sama kiniro_no_corda gatchaman urusei_yatsura aquarion hack major teekyuu inazuma_eleven hokuto_no_ken yuu_yuu_hakusho uchuu_senkan_yamato majutsushi_orphen aria bastard puso_ni_comi bang_dream idolish7 yu_gi_oh mahou_shoujo_lyrical_nanoha show_by_rock huyao_xiao_hongniang doupo_cangqiong yao_shen_ji toriko uchuu_kyoudai queen_s_blade mobile_police_patlabor cardfight_vanguard senki_zesshou_symphogear marvel binan_koukou_chikyuu_boueibu_love yuki_yuna_is_a_hero guyver ookiku_furikabutte fushigi_yuugi saint_seiya digimon muumin saiyuki yama_no_susume beyblade pretty_cure ranma city_hunter ad_police maria_sama mai_hime taiho_shichau_zo starmyu soukyuu_no_fafner saki seikai_no_senki aikatsu angelique glass_no_kamen lodoss_tou_senki d_c stitch xingchen_bian tsukipro_the_animation atom danball_senki gegege_no_kitarou tamayura hidamari_sketch pripara ze_tian_ji kimagure_orange_road wan_jie_xian_zong a_mortal_s_journey harukanaru_toki_no_naka_de sakura_taisen cutey_honey ojamajo_doremi koihime_musou kindaichi_shounen_no_jikenbo wu_geng_ji votoms_finder touch futari_wa_milky_holmes space_cobra captain_tsubasa transformers cyborg dirty_pair ling_yu to_heart el_hazard ultraman di_gi_charat time_bokan konjiki_no_gash_bell jewelpet mazinkaiser jigoku_sensei_nube saber_marionette_j dragon_quest jungle_taitei galaxy_angel shaonian_ge_xing haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura makoto_shinkai mari_okada hayao_miyazaki hiroyuki_imaishi shinichiro_watanabe hiroshi_hamasaki key yasuhiro_takemoto akiyuki_shinbou gen_urobuchi takahiro_oomori hideaki_anno chiaki_kon mamoru_hosoda osamu_tezuka type_moon isao_takahata shoji_kawamori morio_asaka kouji_morimoto masaaki_yuasa satoshi_kon mamoru_oshii masamune_shirow shinji_aramaki yoshiaki_kawajiri kenji_kamiyama junichi_satou clamp go_nagai katsuhiro_otomo kenji_nakamura kouichi_mashimo yoshitaka_amano kunihiko_ikuhara osamu_dezaki rumiko_takahashi leiji_matsumoto yoshiyuki_tomino rintaro ryousuke_takahashi toshio_maeda
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
