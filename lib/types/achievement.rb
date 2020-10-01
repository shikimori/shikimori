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
        shingeki_no_kyojin sword_art_online tokyo_ghoul one_punch_man science_adventure fullmetal_alchemist boku_no_hero_academia naruto ao_no_exorcist nanatsu_no_taizai code_geass psycho_pass bakemonogatari overlord ansatsu_kyoushitsu fate fairy_tail bungou_stray_dogs danmachi durarara mob_psycho darker_than_black kuroshitsuji evangelion shokugeki_no_souma jojo_no_kimyou_na_bouken chuunibyou_demo_koi_ga_shitai suzumiya_haruhi_no_yuuutsu kuroko_no_basket high_school_dxd bleach kamisama_hajimemashita haikyuu hellsing k_on danganronpa toaru_majutsu_no_index when_they_cry hunter_x_hunter ghost_in_the_shell berserk date_a_live k black_lagoon gintama clannad magi one_piece nisekoi bakuman mushishi zero_no_tsukaima puella_magi_sonico_magica natsume_yuujinchou ore_no_imouto saiki_kusuo_no_nan grisaia strike_the_blood shingeki_no_bahamut to_love_ru free devilman full_metal_panic kara_no_kyoukai tales_of kami_nomi_zo_shiru_sekai blood seitokai_yakuindomo jigoku_shoujo rurouni_kenshin love_live sora_no_otoshimono persona working sayonara_zetsubou_sensei arslan_senki hibike_euphonium xxxholic baka_to_test_to_shoukanjuu amagami_ss shakugan_no_shana ashita_no_joe nurarihyon_no_mago chihayafuru rozen_maiden sailor_moon junjou_romantica hoozuki_no_reitetsu ushio_to_tora quanzhi_fashi negima yuru_yuri gundam eureka_seven hakuouki pokemon ginga_eiyuu_densetsu initial_d hitori_no_shita garo uta_no_prince_sama nodame_cantabile little_busters macross tenchi_muyou hajime_no_ippo utawarerumono inuyasha selector_spread_wixoss detective_conan hetalia lupin_iii yozakura_quartet brave_witches tiger_bunny yowamushi_pedal idolmaster terra_formars baki dragon_ball osomatsu_san tsubasa ginga_tetsudou gatchaman aria sengoku_basara minami_ke slayers tegamibachi genshiken ikkitousen cardcaptor_sakura diamond_no_ace dog_days black_jack school_rumble huyao_xiao_hongniang uchuu_senkan_yamato hokuto_no_ken hayate_no_gotoku baku_tech_bakugan hack uchuu_kyoudai slam_dunk aa_megami_sama yuu_yuu_hakusho koneko_no_chi mahou_shoujo_lyrical_nanoha aquarion show_by_rock senki_zesshou_symphogear cardfight_vanguard bang_dream saint_seiya majutsushi_orphen queen_s_blade yu_gi_oh mobile_police_patlabor major kiniro_no_corda binan_koukou_chikyuu_boueibu_love tennis_no_ouji_sama saiyuki teekyuu city_hunter starmyu urusei_yatsura soukyuu_no_fafner toriko inazuma_eleven marvel pripara ookiku_furikabutte aikatsu gegege_no_kitarou pretty_cure maria_sama digimon fushigi_yuugi taiho_shichau_zo tamayura saki ad_police glass_no_kamen ranma d_c mai_hime kimagure_orange_road seikai_no_senki doupo_cangqiong angelique hidamari_sketch cutey_honey beyblade sakura_taisen kindaichi_shounen_no_jikenbo futari_wa_milky_holmes ze_tian_ji time_bokan harukanaru_toki_no_naka_de mazinkaiser koihime_musou votoms_finder cyborg transformers captain_tsubasa dirty_pair to_heart space_cobra el_hazard stitch konjiki_no_gash_bell jigoku_sensei_nube saber_marionette_j di_gi_charat galaxy_angel haou_daikei_ryuu_knight yao_shen_ji re_zero yahari_ore_no_seishun_love_comedy_wa_machigatteiru ling_yu
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hiroshi_hamasaki makoto_shinkai hiroyuki_imaishi hayao_miyazaki akiyuki_shinbou gen_urobuchi key takahiro_oomori shinichiro_watanabe yasuhiro_takemoto chiaki_kon type_moon mamoru_hosoda hideaki_anno shoji_kawamori morio_asaka osamu_tezuka isao_takahata kenji_kamiyama masamune_shirow mamoru_oshii masaaki_yuasa kouji_morimoto clamp satoshi_kon yoshiaki_kawajiri shinji_aramaki junichi_satou kenji_nakamura go_nagai kouichi_mashimo kunihiko_ikuhara katsuhiro_otomo rumiko_takahashi osamu_dezaki yoshitaka_amano yoshiyuki_tomino leiji_matsumoto rintaro ryousuke_takahashi toshio_maeda
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
