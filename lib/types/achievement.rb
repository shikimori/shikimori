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
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto re_zero boku_no_hero_academia fullmetal_alchemist demon_slayer science_adventure nanatsu_no_taizai ao_no_exorcist code_geass overlord ansatsu_kyoushitsu mob_psycho evangelion danmachi bungou_stray_dogs jojo_no_kimyou_na_bouken haikyuu yahari_ore_no_seishun_love_comedy_wa_machigatteiru fairy_tail psycho_pass kuroko_no_basket tensei_shitara_slime_datta_ken bakemonogatari hunter_x_hunter fate shokugeki_no_souma chuunibyou_demo_koi_ga_shitai kuroshitsuji high_school_dxd bleach kamisama_hajimemashita durarara danganronpa hellsing darker_than_black berserk mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on date_a_live when_they_cry quanzhi_gaoshou black_clover one_piece black_lagoon ghost_in_the_shell zero_no_tsukaima nisekoi saiki_kusuo_no_nan k toaru_majutsu_no_index magi bakuman puella_magi_sonico_magica ore_no_imouto grisaia gintama free strike_the_blood clannad devilman to_love_ru shingeki_no_bahamut natsume_yuujinchou mushishi full_metal_panic kami_nomi_zo_shiru_sekai mo_dao_zu_shi sora_no_otoshimono tales_of seitokai_yakuindomo kara_no_kyoukai blood love_live junjou_romantica rurouni_kenshin non_non_biyori fruits_basket ashita_no_joe sailor_moon quanzhi_fashi working baka_to_test_to_shoukanjuu pokemon arslan_senki ushio_to_tora initial_d golden_kamuy uta_no_prince_sama jigoku_shoujo shakugan_no_shana baki rozen_maiden persona hibike_euphonium sayonara_zetsubou_sensei amagami_ss xxxholic chihayafuru hakuouki hajime_no_ippo negima hoozuki_no_reitetsu yuru_yuri dragon_ball tenchi_muyou baku_tech_bakugan hitori_no_shita hetalia gundam yowamushi_pedal garo terra_formars nodame_cantabile lupin_iii utawarerumono inuyasha detective_conan macross eureka_seven ginga_eiyuu_densetsu gochuumon_wa_usagi_desu_ka little_busters ginga_tetsudou slayers dog_days selector_spread_wixoss tiger_bunny brave_witches diamond_no_ace osomatsu_san ikkitousen yozakura_quartet tsubasa minami_ke black_jack koneko_no_chi aa_megami_sama genshiken school_rumble cardcaptor_sakura hayate_no_gotoku sengoku_basara idolmaster slam_dunk kiniro_no_corda gatchaman aquarion tennis_no_ouji_sama hack major teekyuu douluo_dalu hokuto_no_ken inazuma_eleven uchuu_senkan_yamato aria yuu_yuu_hakusho majutsushi_orphen huyao_xiao_hongniang yu_gi_oh mahou_shoujo_lyrical_nanoha bang_dream show_by_rock idolish7 toriko uchuu_kyoudai yao_shen_ji binan_koukou_chikyuu_boueibu_love queen_s_blade senki_zesshou_symphogear cardfight_vanguard marvel yuki_yuna_is_a_hero ookiku_furikabutte doupo_cangqiong mobile_police_patlabor fushigi_yuugi saint_seiya guyver digimon saiyuki starmyu mai_hime ranma maria_sama pretty_cure soukyuu_no_fafner city_hunter saki beyblade ad_police angelique taiho_shichau_zo seikai_no_senki aikatsu glass_no_kamen d_c urusei_yatsura stitch gegege_no_kitarou pripara ze_tian_ji tamayura hidamari_sketch kimagure_orange_road harukanaru_toki_no_naka_de danball_senki sakura_taisen cutey_honey wan_jie_xian_zong koihime_musou kindaichi_shounen_no_jikenbo futari_wa_milky_holmes votoms_finder captain_tsubasa space_cobra ling_yu cyborg transformers time_bokan konjiki_no_gash_bell dirty_pair to_heart el_hazard mazinkaiser jigoku_sensei_nube di_gi_charat saber_marionette_j galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hayao_miyazaki makoto_shinkai hiroyuki_imaishi hiroshi_hamasaki shinichiro_watanabe key yasuhiro_takemoto akiyuki_shinbou takahiro_oomori gen_urobuchi hideaki_anno chiaki_kon mamoru_hosoda type_moon osamu_tezuka isao_takahata shoji_kawamori kouji_morimoto morio_asaka masaaki_yuasa mamoru_oshii satoshi_kon masamune_shirow shinji_aramaki kenji_kamiyama yoshiaki_kawajiri clamp junichi_satou go_nagai katsuhiro_otomo kenji_nakamura kouichi_mashimo kunihiko_ikuhara yoshitaka_amano osamu_dezaki rumiko_takahashi leiji_matsumoto rintaro yoshiyuki_tomino ryousuke_takahashi toshio_maeda
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
