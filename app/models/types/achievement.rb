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
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto demon_slayer re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai ao_no_exorcist overlord code_geass evangelion mob_psycho ansatsu_kyoushitsu jojo_no_kimyou_na_bouken bungou_stray_dogs danmachi haikyuu hunter_x_hunter kaguya_sama tensei_shitara_slime_datta_ken yahari_ore_no_seishun_love_comedy_wa_machigatteiru kuroko_no_basket psycho_pass fairy_tail bakemonogatari bleach fate shokugeki_no_souma chuunibyou_demo_koi_ga_shitai kamisama_hajimemashita high_school_dxd kuroshitsuji berserk hellsing danganronpa durarara darker_than_black mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on black_clover one_piece date_a_live black_lagoon quanzhi_gaoshou when_they_cry saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima toaru_majutsu_no_index k magi bakuman puella_magi_sonico_magica grisaia ore_no_imouto gintama clannad devilman free strike_the_blood to_love_ru shingeki_no_bahamut mo_dao_zu_shi natsume_yuujinchou mushishi full_metal_panic kami_nomi_zo_shiru_sekai fruits_basket sora_no_otoshimono kara_no_kyoukai seitokai_yakuindomo tales_of blood love_live non_non_biyori baki ashita_no_joe rurouni_kenshin junjou_romantica quanzhi_fashi golden_kamuy sailor_moon initial_d pokemon karakai_jouzu_no_takagi_san working baka_to_test_to_shoukanjuu arslan_senki honzuki_no_gekokujou ushio_to_tora uta_no_prince_sama jigoku_shoujo shakugan_no_shana hibike_euphonium persona rozen_maiden xxxholic sayonara_zetsubou_sensei amagami_ss hajime_no_ippo chihayafuru negima hakuouki hoozuki_no_reitetsu dragon_ball gundam yuru_yuri baku_tech_bakugan yi_ren_zhi_xia tenchi_muyou hetalia yowamushi_pedal terra_formars lupin_iii garo nodame_cantabile utawarerumono inuyasha detective_conan ginga_eiyuu_densetsu macross gochuumon_wa_usagi_desu_ka eureka_seven little_busters ginga_tetsudou slayers schwarzesmarken dog_days kingdom brave_witches selector_spread_wixoss tiger_bunny diamond_no_ace osomatsu_san ikkitousen yozakura_quartet minami_ke koneko_no_chi tsubasa black_jack aa_megami_sama slam_dunk genshiken cardcaptor_sakura school_rumble jashin_chan_dropkick hayate_no_gotoku idolmaster sengoku_basara aggressive_retsuko tennis_no_ouji_sama kiniro_no_corda gatchaman aquarion hack major teekyuu inazuma_eleven urusei_yatsura hokuto_no_ken yuu_yuu_hakusho uchuu_senkan_yamato majutsushi_orphen puso_ni_comi aria idolish7 bang_dream yu_gi_oh mahou_shoujo_lyrical_nanoha show_by_rock huyao_xiao_hongniang yao_shen_ji toriko uchuu_kyoudai doupo_cangqiong queen_s_blade cardfight_vanguard senki_zesshou_symphogear binan_koukou_chikyuu_boueibu_love mobile_police_patlabor marvel yuki_yuna_is_a_hero ookiku_furikabutte fushigi_yuugi saint_seiya guyver digimon saiyuki yama_no_susume ranma mai_hime maria_sama city_hunter pretty_cure beyblade starmyu ad_police taiho_shichau_zo soukyuu_no_fafner saki seikai_no_senki angelique aikatsu glass_no_kamen d_c stitch tsukipro_the_animation atom gegege_no_kitarou tamayura xingchen_bian pripara ze_tian_ji danball_senki hidamari_sketch kimagure_orange_road wan_jie_xian_zong harukanaru_toki_no_naka_de sakura_taisen cutey_honey koihime_musou kindaichi_shounen_no_jikenbo wu_geng_ji votoms_finder futari_wa_milky_holmes touch captain_tsubasa space_cobra transformers cyborg ling_yu dirty_pair to_heart el_hazard time_bokan konjiki_no_gash_bell di_gi_charat mazinkaiser jigoku_sensei_nube saber_marionette_j galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura makoto_shinkai mari_okada hayao_miyazaki hiroyuki_imaishi shinichiro_watanabe hiroshi_hamasaki key yasuhiro_takemoto akiyuki_shinbou gen_urobuchi takahiro_oomori hideaki_anno chiaki_kon mamoru_hosoda osamu_tezuka type_moon isao_takahata shoji_kawamori kouji_morimoto masaaki_yuasa morio_asaka satoshi_kon mamoru_oshii masamune_shirow shinji_aramaki kenji_kamiyama yoshiaki_kawajiri junichi_satou clamp go_nagai katsuhiro_otomo kenji_nakamura kouichi_mashimo yoshitaka_amano kunihiko_ikuhara osamu_dezaki rumiko_takahashi leiji_matsumoto yoshiyuki_tomino rintaro ryousuke_takahashi toshio_maeda
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
