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
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai ao_no_exorcist overlord code_geass ansatsu_kyoushitsu mob_psycho danmachi bungou_stray_dogs evangelion jojo_no_kimyou_na_bouken fairy_tail yahari_ore_no_seishun_love_comedy_wa_machigatteiru psycho_pass haikyuu bakemonogatari kuroko_no_basket fate shokugeki_no_souma kuroshitsuji tensei_shitara_slime_datta_ken chuunibyou_demo_koi_ga_shitai high_school_dxd kamisama_hajimemashita hunter_x_hunter bleach durarara darker_than_black danganronpa hellsing suzumiya_haruhi_no_yuuutsu k_on berserk date_a_live when_they_cry quanzhi_gaoshou one_piece black_lagoon zero_no_tsukaima nisekoi k ghost_in_the_shell toaru_majutsu_no_index magi saiki_kusuo_no_nan bakuman ore_no_imouto puella_magi_sonico_magica grisaia strike_the_blood gintama free clannad devilman to_love_ru shingeki_no_bahamut natsume_yuujinchou mushishi full_metal_panic kami_nomi_zo_shiru_sekai sora_no_otoshimono tales_of seitokai_yakuindomo kara_no_kyoukai blood love_live junjou_romantica rurouni_kenshin non_non_biyori sailor_moon working ashita_no_joe baka_to_test_to_shoukanjuu quanzhi_fashi arslan_senki pokemon uta_no_prince_sama fruits_basket ushio_to_tora shakugan_no_shana jigoku_shoujo golden_kamuy initial_d rozen_maiden persona hibike_euphonium sayonara_zetsubou_sensei amagami_ss chihayafuru xxxholic hakuouki baki hoozuki_no_reitetsu negima hajime_no_ippo yuru_yuri tenchi_muyou hetalia yowamushi_pedal hitori_no_shita garo gundam baku_tech_bakugan dragon_ball terra_formars nodame_cantabile utawarerumono detective_conan inuyasha macross lupin_iii eureka_seven little_busters ginga_tetsudou gochuumon_wa_usagi_desu_ka ginga_eiyuu_densetsu dog_days slayers selector_spread_wixoss tiger_bunny brave_witches diamond_no_ace osomatsu_san ikkitousen yozakura_quartet tsubasa minami_ke aa_megami_sama black_jack koneko_no_chi genshiken school_rumble cardcaptor_sakura hayate_no_gotoku sengoku_basara idolmaster kiniro_no_corda gatchaman slam_dunk aquarion hack major teekyuu hokuto_no_ken uchuu_senkan_yamato tennis_no_ouji_sama inazuma_eleven douluo_dalu aria huyao_xiao_hongniang yuu_yuu_hakusho majutsushi_orphen yu_gi_oh show_by_rock mahou_shoujo_lyrical_nanoha bang_dream idolish7 toriko uchuu_kyoudai yao_shen_ji binan_koukou_chikyuu_boueibu_love cardfight_vanguard queen_s_blade senki_zesshou_symphogear marvel ookiku_furikabutte saint_seiya fushigi_yuugi mobile_police_patlabor guyver saiyuki digimon doupo_cangqiong starmyu mai_hime ranma maria_sama soukyuu_no_fafner pretty_cure saki city_hunter angelique beyblade aikatsu glass_no_kamen seikai_no_senki ad_police d_c taiho_shichau_zo urusei_yatsura gegege_no_kitarou pripara stitch tamayura ze_tian_ji hidamari_sketch kimagure_orange_road harukanaru_toki_no_naka_de sakura_taisen danball_senki cutey_honey koihime_musou kindaichi_shounen_no_jikenbo futari_wa_milky_holmes votoms_finder wan_jie_xian_zong captain_tsubasa ling_yu cyborg space_cobra transformers time_bokan to_heart konjiki_no_gash_bell el_hazard dirty_pair mazinkaiser saber_marionette_j jigoku_sensei_nube di_gi_charat galaxy_angel haou_daikei_ryuu_knight mahouka_koukou_no_rettousei
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hayao_miyazaki makoto_shinkai hiroyuki_imaishi hiroshi_hamasaki shinichiro_watanabe key yasuhiro_takemoto akiyuki_shinbou takahiro_oomori gen_urobuchi chiaki_kon hideaki_anno mamoru_hosoda type_moon isao_takahata osamu_tezuka shoji_kawamori kouji_morimoto morio_asaka masaaki_yuasa mamoru_oshii masamune_shirow shinji_aramaki satoshi_kon kenji_kamiyama yoshiaki_kawajiri clamp junichi_satou go_nagai katsuhiro_otomo kenji_nakamura kouichi_mashimo kunihiko_ikuhara yoshitaka_amano osamu_dezaki rumiko_takahashi leiji_matsumoto rintaro yoshiyuki_tomino ryousuke_takahashi toshio_maeda
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
