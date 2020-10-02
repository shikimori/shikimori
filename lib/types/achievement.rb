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
        shingeki_no_kyojin sword_art_online tokyo_ghoul one_punch_man science_adventure fullmetal_alchemist re_zero naruto boku_no_hero_academia ao_no_exorcist nanatsu_no_taizai code_geass psycho_pass bakemonogatari overlord ansatsu_kyoushitsu fate bungou_stray_dogs fairy_tail mob_psycho danmachi durarara yahari_ore_no_seishun_love_comedy_wa_machigatteiru darker_than_black kuroshitsuji evangelion jojo_no_kimyou_na_bouken shokugeki_no_souma chuunibyou_demo_koi_ga_shitai suzumiya_haruhi_no_yuuutsu kuroko_no_basket high_school_dxd bleach haikyuu kamisama_hajimemashita hellsing danganronpa hunter_x_hunter k_on when_they_cry toaru_majutsu_no_index berserk ghost_in_the_shell date_a_live k black_lagoon gintama clannad magi one_piece nisekoi bakuman mushishi puella_magi_sonico_magica zero_no_tsukaima natsume_yuujinchou saiki_kusuo_no_nan ore_no_imouto grisaia strike_the_blood shingeki_no_bahamut to_love_ru free devilman full_metal_panic kara_no_kyoukai tales_of kami_nomi_zo_shiru_sekai blood seitokai_yakuindomo jigoku_shoujo rurouni_kenshin love_live sora_no_otoshimono persona working sayonara_zetsubou_sensei hibike_euphonium arslan_senki xxxholic baka_to_test_to_shoukanjuu amagami_ss shakugan_no_shana ashita_no_joe nurarihyon_no_mago chihayafuru sailor_moon rozen_maiden junjou_romantica hoozuki_no_reitetsu quanzhi_fashi ushio_to_tora negima yuru_yuri pokemon gundam initial_d hakuouki ginga_eiyuu_densetsu eureka_seven hitori_no_shita garo uta_no_prince_sama little_busters nodame_cantabile macross tenchi_muyou hajime_no_ippo inuyasha utawarerumono detective_conan lupin_iii selector_spread_wixoss hetalia yozakura_quartet brave_witches yowamushi_pedal tiger_bunny baki idolmaster terra_formars dragon_ball osomatsu_san tsubasa ginga_tetsudou gatchaman aria minami_ke slayers sengoku_basara genshiken tegamibachi cardcaptor_sakura ikkitousen diamond_no_ace black_jack dog_days school_rumble huyao_xiao_hongniang uchuu_senkan_yamato hokuto_no_ken baku_tech_bakugan hayate_no_gotoku uchuu_kyoudai hack slam_dunk yuu_yuu_hakusho aa_megami_sama mahou_shoujo_lyrical_nanoha koneko_no_chi aquarion show_by_rock senki_zesshou_symphogear bang_dream cardfight_vanguard saint_seiya majutsushi_orphen mobile_police_patlabor queen_s_blade yu_gi_oh major kiniro_no_corda binan_koukou_chikyuu_boueibu_love saiyuki tennis_no_ouji_sama teekyuu city_hunter urusei_yatsura starmyu soukyuu_no_fafner toriko inazuma_eleven marvel ookiku_furikabutte aikatsu gegege_no_kitarou pretty_cure maria_sama yao_shen_ji digimon pripara taiho_shichau_zo fushigi_yuugi tamayura ad_police saki ranma glass_no_kamen mai_hime d_c kimagure_orange_road seikai_no_senki doupo_cangqiong angelique hidamari_sketch cutey_honey beyblade sakura_taisen kindaichi_shounen_no_jikenbo ze_tian_ji futari_wa_milky_holmes time_bokan harukanaru_toki_no_naka_de mazinkaiser votoms_finder koihime_musou cyborg captain_tsubasa transformers dirty_pair to_heart space_cobra ling_yu stitch el_hazard konjiki_no_gash_bell jigoku_sensei_nube saber_marionette_j di_gi_charat galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hiroshi_hamasaki makoto_shinkai hiroyuki_imaishi hayao_miyazaki akiyuki_shinbou gen_urobuchi key takahiro_oomori shinichiro_watanabe yasuhiro_takemoto chiaki_kon type_moon mamoru_hosoda hideaki_anno shoji_kawamori osamu_tezuka morio_asaka isao_takahata kenji_kamiyama masamune_shirow masaaki_yuasa mamoru_oshii kouji_morimoto clamp satoshi_kon yoshiaki_kawajiri junichi_satou shinji_aramaki kenji_nakamura go_nagai kouichi_mashimo kunihiko_ikuhara katsuhiro_otomo rumiko_takahashi osamu_dezaki yoshitaka_amano yoshiyuki_tomino leiji_matsumoto rintaro ryousuke_takahashi toshio_maeda
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
