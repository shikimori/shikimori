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
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai ao_no_exorcist overlord code_geass ansatsu_kyoushitsu mob_psycho danmachi evangelion bungou_stray_dogs jojo_no_kimyou_na_bouken yahari_ore_no_seishun_love_comedy_wa_machigatteiru fairy_tail haikyuu psycho_pass bakemonogatari kuroko_no_basket fate tensei_shitara_slime_datta_ken shokugeki_no_souma kuroshitsuji chuunibyou_demo_koi_ga_shitai hunter_x_hunter high_school_dxd kamisama_hajimemashita bleach durarara darker_than_black danganronpa hellsing mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on berserk date_a_live when_they_cry quanzhi_gaoshou one_piece black_lagoon zero_no_tsukaima nisekoi ghost_in_the_shell k toaru_majutsu_no_index magi saiki_kusuo_no_nan bakuman ore_no_imouto puella_magi_sonico_magica grisaia gintama strike_the_blood free clannad devilman to_love_ru shingeki_no_bahamut natsume_yuujinchou mushishi full_metal_panic kami_nomi_zo_shiru_sekai sora_no_otoshimono tales_of seitokai_yakuindomo kara_no_kyoukai blood love_live junjou_romantica rurouni_kenshin non_non_biyori sailor_moon ashita_no_joe working quanzhi_fashi baka_to_test_to_shoukanjuu fruits_basket arslan_senki pokemon uta_no_prince_sama ushio_to_tora initial_d golden_kamuy shakugan_no_shana jigoku_shoujo rozen_maiden persona hibike_euphonium sayonara_zetsubou_sensei amagami_ss chihayafuru xxxholic baki hakuouki hoozuki_no_reitetsu negima hajime_no_ippo yuru_yuri tenchi_muyou hetalia dragon_ball hitori_no_shita baku_tech_bakugan yowamushi_pedal gundam garo terra_formars nodame_cantabile utawarerumono detective_conan inuyasha lupin_iii macross eureka_seven little_busters gochuumon_wa_usagi_desu_ka ginga_eiyuu_densetsu ginga_tetsudou dog_days slayers selector_spread_wixoss tiger_bunny brave_witches diamond_no_ace osomatsu_san ikkitousen yozakura_quartet tsubasa minami_ke black_jack aa_megami_sama koneko_no_chi genshiken cardcaptor_sakura school_rumble hayate_no_gotoku sengoku_basara idolmaster slam_dunk kiniro_no_corda gatchaman aquarion hack major teekyuu hokuto_no_ken uchuu_senkan_yamato inazuma_eleven tennis_no_ouji_sama douluo_dalu aria yuu_yuu_hakusho huyao_xiao_hongniang majutsushi_orphen show_by_rock yu_gi_oh mahou_shoujo_lyrical_nanoha bang_dream idolish7 toriko uchuu_kyoudai yao_shen_ji binan_koukou_chikyuu_boueibu_love queen_s_blade cardfight_vanguard senki_zesshou_symphogear marvel ookiku_furikabutte saint_seiya fushigi_yuugi mobile_police_patlabor guyver digimon doupo_cangqiong saiyuki starmyu mai_hime ranma maria_sama soukyuu_no_fafner pretty_cure city_hunter saki angelique beyblade aikatsu seikai_no_senki ad_police glass_no_kamen taiho_shichau_zo d_c urusei_yatsura gegege_no_kitarou stitch pripara tamayura ze_tian_ji hidamari_sketch kimagure_orange_road harukanaru_toki_no_naka_de sakura_taisen danball_senki cutey_honey koihime_musou kindaichi_shounen_no_jikenbo wan_jie_xian_zong futari_wa_milky_holmes votoms_finder captain_tsubasa ling_yu cyborg space_cobra transformers time_bokan to_heart konjiki_no_gash_bell el_hazard dirty_pair mazinkaiser saber_marionette_j jigoku_sensei_nube di_gi_charat galaxy_angel haou_daikei_ryuu_knight mo_dao_zu_shi
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hayao_miyazaki makoto_shinkai hiroyuki_imaishi hiroshi_hamasaki shinichiro_watanabe key yasuhiro_takemoto akiyuki_shinbou takahiro_oomori gen_urobuchi chiaki_kon hideaki_anno mamoru_hosoda type_moon osamu_tezuka isao_takahata shoji_kawamori kouji_morimoto morio_asaka masaaki_yuasa mamoru_oshii masamune_shirow satoshi_kon shinji_aramaki kenji_kamiyama yoshiaki_kawajiri clamp junichi_satou go_nagai katsuhiro_otomo kenji_nakamura kouichi_mashimo kunihiko_ikuhara yoshitaka_amano osamu_dezaki rumiko_takahashi leiji_matsumoto rintaro yoshiyuki_tomino ryousuke_takahashi toshio_maeda
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
