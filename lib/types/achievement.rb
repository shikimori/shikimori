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
        shingeki_no_kyojin tokyo_ghoul sword_art_online one_punch_man naruto re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai ao_no_exorcist overlord code_geass ansatsu_kyoushitsu mob_psycho danmachi bungou_stray_dogs fairy_tail evangelion yahari_ore_no_seishun_love_comedy_wa_machigatteiru psycho_pass jojo_no_kimyou_na_bouken bakemonogatari haikyuu kuroko_no_basket shokugeki_no_souma fate kuroshitsuji chuunibyou_demo_koi_ga_shitai high_school_dxd kamisama_hajimemashita bleach durarara hunter_x_hunter darker_than_black danganronpa hellsing suzumiya_haruhi_no_yuuutsu k_on berserk date_a_live when_they_cry quanzhi_gaoshou zero_no_tsukaima k nisekoi black_lagoon one_piece ghost_in_the_shell toaru_majutsu_no_index magi bakuman saiki_kusuo_no_nan ore_no_imouto strike_the_blood puella_magi_sonico_magica grisaia gintama free clannad to_love_ru devilman shingeki_no_bahamut natsume_yuujinchou full_metal_panic mushishi kami_nomi_zo_shiru_sekai sora_no_otoshimono tales_of seitokai_yakuindomo kara_no_kyoukai love_live blood junjou_romantica rurouni_kenshin working sailor_moon baka_to_test_to_shoukanjuu arslan_senki quanzhi_fashi pokemon uta_no_prince_sama ashita_no_joe ushio_to_tora shakugan_no_shana jigoku_shoujo rozen_maiden persona initial_d golden_kamuy amagami_ss sayonara_zetsubou_sensei hibike_euphonium chihayafuru hakuouki xxxholic hoozuki_no_reitetsu negima baki yuru_yuri hajime_no_ippo tenchi_muyou hetalia yowamushi_pedal garo gundam hitori_no_shita terra_formars baku_tech_bakugan dragon_ball nodame_cantabile utawarerumono detective_conan inuyasha eureka_seven macross lupin_iii ginga_tetsudou little_busters gochuumon_wa_usagi_desu_ka dog_days ginga_eiyuu_densetsu slayers selector_spread_wixoss tiger_bunny brave_witches osomatsu_san diamond_no_ace ikkitousen yozakura_quartet tsubasa minami_ke aa_megami_sama black_jack koneko_no_chi genshiken school_rumble cardcaptor_sakura hayate_no_gotoku sengoku_basara idolmaster kiniro_no_corda gatchaman aquarion slam_dunk hack major teekyuu hokuto_no_ken uchuu_senkan_yamato tennis_no_ouji_sama inazuma_eleven aria huyao_xiao_hongniang show_by_rock yu_gi_oh douluo_dalu yuu_yuu_hakusho mahou_shoujo_lyrical_nanoha majutsushi_orphen bang_dream toriko idolish7 uchuu_kyoudai yao_shen_ji binan_koukou_chikyuu_boueibu_love cardfight_vanguard queen_s_blade senki_zesshou_symphogear marvel ookiku_furikabutte saint_seiya fushigi_yuugi mobile_police_patlabor saiyuki digimon starmyu doupo_cangqiong mai_hime ranma soukyuu_no_fafner maria_sama angelique saki pretty_cure transformers city_hunter glass_no_kamen aikatsu seikai_no_senki d_c beyblade taiho_shichau_zo ad_police urusei_yatsura gegege_no_kitarou pripara ze_tian_ji tamayura stitch hidamari_sketch harukanaru_toki_no_naka_de kimagure_orange_road sakura_taisen koihime_musou cutey_honey futari_wa_milky_holmes kindaichi_shounen_no_jikenbo captain_tsubasa votoms_finder ling_yu cyborg space_cobra time_bokan to_heart konjiki_no_gash_bell el_hazard dirty_pair mazinkaiser saber_marionette_j jigoku_sensei_nube di_gi_charat galaxy_angel haou_daikei_ryuu_knight non_non_biyori danball_senki
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hayao_miyazaki makoto_shinkai hiroyuki_imaishi hiroshi_hamasaki key shinichiro_watanabe yasuhiro_takemoto akiyuki_shinbou gen_urobuchi takahiro_oomori chiaki_kon hideaki_anno mamoru_hosoda type_moon isao_takahata osamu_tezuka shoji_kawamori morio_asaka kouji_morimoto masaaki_yuasa mamoru_oshii masamune_shirow shinji_aramaki kenji_kamiyama satoshi_kon yoshiaki_kawajiri clamp junichi_satou go_nagai kenji_nakamura katsuhiro_otomo kouichi_mashimo kunihiko_ikuhara yoshitaka_amano osamu_dezaki rumiko_takahashi leiji_matsumoto rintaro yoshiyuki_tomino ryousuke_takahashi toshio_maeda
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
