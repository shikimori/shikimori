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
        shingeki_no_kyojin sword_art_online tokyo_ghoul one_punch_man science_adventure fullmetal_alchemist re_zero naruto boku_no_hero_academia ao_no_exorcist nanatsu_no_taizai code_geass psycho_pass bakemonogatari overlord ansatsu_kyoushitsu fate bungou_stray_dogs fairy_tail danmachi mob_psycho durarara yahari_ore_no_seishun_love_comedy_wa_machigatteiru darker_than_black kuroshitsuji evangelion jojo_no_kimyou_na_bouken shokugeki_no_souma chuunibyou_demo_koi_ga_shitai suzumiya_haruhi_no_yuuutsu bleach kuroko_no_basket high_school_dxd haikyuu kamisama_hajimemashita hellsing hunter_x_hunter when_they_cry danganronpa k_on toaru_majutsu_no_index berserk ghost_in_the_shell date_a_live k black_lagoon gintama clannad magi one_piece nisekoi bakuman mushishi puella_magi_sonico_magica zero_no_tsukaima natsume_yuujinchou saiki_kusuo_no_nan grisaia ore_no_imouto strike_the_blood shingeki_no_bahamut free to_love_ru devilman full_metal_panic kara_no_kyoukai tales_of kami_nomi_zo_shiru_sekai blood seitokai_yakuindomo jigoku_shoujo rurouni_kenshin love_live persona sora_no_otoshimono working sayonara_zetsubou_sensei arslan_senki hibike_euphonium xxxholic amagami_ss baka_to_test_to_shoukanjuu ashita_no_joe shakugan_no_shana nurarihyon_no_mago chihayafuru sailor_moon rozen_maiden junjou_romantica quanzhi_fashi hoozuki_no_reitetsu ushio_to_tora negima yuru_yuri pokemon hakuouki initial_d gundam ginga_eiyuu_densetsu eureka_seven hitori_no_shita garo uta_no_prince_sama little_busters nodame_cantabile macross tenchi_muyou inuyasha hajime_no_ippo utawarerumono selector_spread_wixoss hetalia brave_witches lupin_iii detective_conan yozakura_quartet tiger_bunny baki yowamushi_pedal idolmaster terra_formars dragon_ball osomatsu_san tsubasa ginga_tetsudou gatchaman aria slayers minami_ke sengoku_basara genshiken tegamibachi ikkitousen cardcaptor_sakura black_jack school_rumble dog_days diamond_no_ace huyao_xiao_hongniang hokuto_no_ken baku_tech_bakugan uchuu_senkan_yamato hayate_no_gotoku hack uchuu_kyoudai aa_megami_sama slam_dunk yuu_yuu_hakusho koneko_no_chi show_by_rock aquarion mahou_shoujo_lyrical_nanoha senki_zesshou_symphogear bang_dream cardfight_vanguard majutsushi_orphen mobile_police_patlabor queen_s_blade yu_gi_oh saint_seiya kiniro_no_corda binan_koukou_chikyuu_boueibu_love major tennis_no_ouji_sama saiyuki teekyuu city_hunter urusei_yatsura starmyu soukyuu_no_fafner toriko inazuma_eleven ookiku_furikabutte marvel aikatsu gegege_no_kitarou pretty_cure yao_shen_ji maria_sama taiho_shichau_zo pripara digimon fushigi_yuugi ad_police tamayura saki ranma mai_hime d_c kimagure_orange_road seikai_no_senki doupo_cangqiong glass_no_kamen angelique hidamari_sketch beyblade cutey_honey sakura_taisen ze_tian_ji kindaichi_shounen_no_jikenbo futari_wa_milky_holmes time_bokan harukanaru_toki_no_naka_de mazinkaiser koihime_musou votoms_finder cyborg captain_tsubasa dirty_pair transformers to_heart space_cobra ling_yu stitch el_hazard konjiki_no_gash_bell jigoku_sensei_nube saber_marionette_j di_gi_charat galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hiroshi_hamasaki makoto_shinkai hiroyuki_imaishi hayao_miyazaki akiyuki_shinbou gen_urobuchi key shinichiro_watanabe takahiro_oomori yasuhiro_takemoto chiaki_kon type_moon hideaki_anno mamoru_hosoda shoji_kawamori osamu_tezuka morio_asaka isao_takahata kenji_kamiyama masamune_shirow masaaki_yuasa mamoru_oshii kouji_morimoto clamp satoshi_kon yoshiaki_kawajiri junichi_satou shinji_aramaki kenji_nakamura go_nagai kouichi_mashimo kunihiko_ikuhara katsuhiro_otomo yoshitaka_amano rumiko_takahashi osamu_dezaki yoshiyuki_tomino leiji_matsumoto rintaro ryousuke_takahashi toshio_maeda
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
