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
      # rubocop:disable LineLength
      NekoGroup[:franchise] => %i[
        shingeki_no_kyojin sword_art_online tokyo_ghoul science_adventure fullmetal_alchemist naruto boku_no_hero_academia ao_no_exorcist code_geass nanatsu_no_taizai bakemonogatari overlord fairy_tail fate ansatsu_kyoushitsu durarara bungou_stray_dogs darker_than_black kuroshitsuji chuunibyou_demo_koi_ga_shitai shokugeki_no_souma evangelion suzumiya_haruhi_no_yuuutsu kuroko_no_basket high_school_dxd jojo_no_kimyou_na_bouken bleach kamisama_hajimemashita hellsing k_on danganronpa haikyuu when_they_cry k date_a_live toaru_majutsu_no_index ghost_in_the_shell berserk gintama hunter_x_hunter magi clannad nisekoi bakuman one_piece natsume_yuujinchou zero_no_tsukaima mushishi shingeki_no_bahamut saiki_kusuo_no_nan to_love_ru free full_metal_panic tales_of kara_no_kyoukai devilman kami_nomi_zo_shiru_sekai blood seitokai_yakuindomo jigoku_shoujo persona love_live sora_no_otoshimono rurouni_kenshin working arslan_senki sayonara_zetsubou_sensei hibike_euphonium xxxholic shakugan_no_shana amagami_ss ashita_no_joe nurarihyon_no_mago rozen_maiden junjou_romantica eureka_seven chihayafuru hoozuki_no_reitetsu ushio_to_tora sailor_moon negima yuru_yuri hakuouki gundam garo uta_no_prince_sama nodame_cantabile little_busters pokemon macross tenchi_muyou initial_d ginga_eiyuu_densetsu utawarerumono detective_conan hetalia selector_spread_wixoss yowamushi_pedal hajime_no_ippo yozakura_quartet tiger_bunny brave_witches idolmaster inuyasha lupin_iii osomatsu_san tsubasa dragon_ball baki gatchaman ginga_tetsudou sengoku_basara minami_ke ikkitousen tegamibachi aria genshiken slayers dog_days cardcaptor_sakura school_rumble black_jack diamond_no_ace uchuu_senkan_yamato hayate_no_gotoku hokuto_no_ken hack aa_megami_sama uchuu_kyoudai aquarion koneko_no_chi mahou_shoujo_lyrical_nanoha yuu_yuu_hakusho cardfight_vanguard slam_dunk baku_tech_bakugan saint_seiya binan_koukou_chikyuu_boueibu_love kiniro_no_corda queen_s_blade saiyuki yu_gi_oh major tennis_no_ouji_sama teekyuu mobile_police_patlabor gegege_no_kitarou senki_zesshou_symphogear city_hunter soukyuu_no_fafner toriko marvel pripara urusei_yatsura ookiku_furikabutte aikatsu inazuma_eleven pretty_cure maria_sama digimon fushigi_yuugi saki tamayura glass_no_kamen d_c mai_hime ranma angelique ad_police taiho_shichau_zo seikai_no_senki kimagure_orange_road hidamari_sketch mazinkaiser cutey_honey beyblade futari_wa_milky_holmes time_bokan kindaichi_shounen_no_jikenbo cyborg doraemon votoms_finder captain_tsubasa transformers to_heart sakura_taisen dirty_pair space_cobra konjiki_no_gash_bell el_hazard saber_marionette_j di_gi_charat galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tensai_okamura hiroyuki_imaishi akiyuki_shinbou makoto_shinkai hayao_miyazaki gen_urobuchi key shinichiro_watanabe type_moon hideaki_anno shoji_kawamori mamoru_hosoda isao_takahata osamu_tezuka kenji_kamiyama masamune_shirow mamoru_oshii kouji_morimoto clamp masaaki_yuasa satoshi_kon yoshiaki_kawajiri kenji_nakamura shinji_aramaki kouichi_mashimo go_nagai ryousuke_takahashi kunihiko_ikuhara katsuhiro_otomo yoshiyuki_tomino rumiko_takahashi osamu_dezaki leiji_matsumoto yoshitaka_amano rintaro tomoharu_katsumata toshio_maeda
      ]
      # rubocop:enable LineLength
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
