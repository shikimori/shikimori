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
        shingeki_no_kyojin tokyo_ghoul sword_art_online one_punch_man naruto re_zero boku_no_hero_academia fullmetal_alchemist science_adventure ao_no_exorcist nanatsu_no_taizai overlord code_geass ansatsu_kyoushitsu danmachi mob_psycho fairy_tail bungou_stray_dogs psycho_pass yahari_ore_no_seishun_love_comedy_wa_machigatteiru evangelion bakemonogatari jojo_no_kimyou_na_bouken kuroko_no_basket shokugeki_no_souma fate kuroshitsuji chuunibyou_demo_koi_ga_shitai haikyuu high_school_dxd kamisama_hajimemashita durarara bleach darker_than_black danganronpa hellsing suzumiya_haruhi_no_yuuutsu k_on hunter_x_hunter berserk date_a_live when_they_cry zero_no_tsukaima k nisekoi black_lagoon toaru_majutsu_no_index one_piece ghost_in_the_shell magi bakuman ore_no_imouto saiki_kusuo_no_nan strike_the_blood grisaia puella_magi_sonico_magica gintama clannad free to_love_ru shingeki_no_bahamut devilman natsume_yuujinchou full_metal_panic mushishi kami_nomi_zo_shiru_sekai sora_no_otoshimono tales_of seitokai_yakuindomo kara_no_kyoukai love_live blood junjou_romantica rurouni_kenshin working baka_to_test_to_shoukanjuu sailor_moon arslan_senki quanzhi_fashi uta_no_prince_sama pokemon ashita_no_joe ushio_to_tora nurarihyon_no_mago shakugan_no_shana jigoku_shoujo persona rozen_maiden initial_d amagami_ss sayonara_zetsubou_sensei hibike_euphonium chihayafuru hakuouki xxxholic hoozuki_no_reitetsu negima baki yuru_yuri hajime_no_ippo tenchi_muyou hetalia yowamushi_pedal garo gundam terra_formars hitori_no_shita nodame_cantabile baku_tech_bakugan dragon_ball utawarerumono detective_conan eureka_seven macross inuyasha lupin_iii ginga_tetsudou little_busters dog_days slayers selector_spread_wixoss ginga_eiyuu_densetsu tiger_bunny brave_witches osomatsu_san diamond_no_ace ikkitousen yozakura_quartet tsubasa minami_ke aa_megami_sama black_jack koneko_no_chi tegamibachi genshiken school_rumble hayate_no_gotoku cardcaptor_sakura sengoku_basara idolmaster kiniro_no_corda gatchaman aquarion slam_dunk hack major teekyuu uchuu_senkan_yamato tennis_no_ouji_sama hokuto_no_ken inazuma_eleven aria huyao_xiao_hongniang yu_gi_oh show_by_rock yuu_yuu_hakusho mahou_shoujo_lyrical_nanoha bang_dream majutsushi_orphen toriko uchuu_kyoudai binan_koukou_chikyuu_boueibu_love yao_shen_ji cardfight_vanguard queen_s_blade senki_zesshou_symphogear marvel ookiku_furikabutte fushigi_yuugi saint_seiya mobile_police_patlabor saiyuki digimon starmyu mai_hime doupo_cangqiong ranma soukyuu_no_fafner angelique maria_sama saki pretty_cure glass_no_kamen aikatsu city_hunter beyblade d_c seikai_no_senki taiho_shichau_zo ad_police transformers urusei_yatsura gegege_no_kitarou pripara tamayura ze_tian_ji stitch harukanaru_toki_no_naka_de hidamari_sketch kimagure_orange_road sakura_taisen koihime_musou cutey_honey futari_wa_milky_holmes kindaichi_shounen_no_jikenbo cyborg captain_tsubasa votoms_finder ling_yu time_bokan space_cobra konjiki_no_gash_bell to_heart el_hazard mazinkaiser dirty_pair saber_marionette_j di_gi_charat jigoku_sensei_nube galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hayao_miyazaki makoto_shinkai hiroyuki_imaishi hiroshi_hamasaki key shinichiro_watanabe yasuhiro_takemoto akiyuki_shinbou gen_urobuchi takahiro_oomori chiaki_kon mamoru_hosoda hideaki_anno type_moon isao_takahata osamu_tezuka shoji_kawamori morio_asaka kouji_morimoto masaaki_yuasa mamoru_oshii masamune_shirow shinji_aramaki kenji_kamiyama satoshi_kon yoshiaki_kawajiri clamp junichi_satou go_nagai kenji_nakamura katsuhiro_otomo kouichi_mashimo kunihiko_ikuhara yoshitaka_amano osamu_dezaki rumiko_takahashi leiji_matsumoto yoshiyuki_tomino rintaro ryousuke_takahashi toshio_maeda
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
