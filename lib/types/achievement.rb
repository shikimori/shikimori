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
        sword_art_online shingeki_no_kyojin tokyo_ghoul science_adventure fullmetal_alchemist naruto boku_no_hero_academia ao_no_exorcist code_geass nanatsu_no_taizai bakemonogatari overlord fairy_tail fate ansatsu_kyoushitsu durarara darker_than_black kuroshitsuji chuunibyou_demo_koi_ga_shitai shokugeki_no_souma evangelion suzumiya_haruhi_no_yuuutsu kuroko_no_basket high_school_dxd jojo_no_kimyou_na_bouken bleach kamisama_hajimemashita hellsing k_on danganronpa haikyuu when_they_cry k date_a_live toaru_majutsu_no_index ghost_in_the_shell berserk gintama hunter_x_hunter magi clannad nisekoi bakuman one_piece natsume_yuujinchou zero_no_tsukaima mushishi shingeki_no_bahamut saiki_kusuo_no_nan to_love_ru free tales_of full_metal_panic kara_no_kyoukai devilman kami_nomi_zo_shiru_sekai blood seitokai_yakuindomo jigoku_shoujo persona love_live sora_no_otoshimono rurouni_kenshin working arslan_senki sayonara_zetsubou_sensei xxxholic hibike_euphonium shakugan_no_shana amagami_ss ashita_no_joe nurarihyon_no_mago rozen_maiden junjou_romantica eureka_seven hoozuki_no_reitetsu chihayafuru ushio_to_tora sailor_moon negima yuru_yuri hakuouki gundam garo uta_no_prince_sama nodame_cantabile little_busters pokemon macross tenchi_muyou initial_d ginga_eiyuu_densetsu utawarerumono detective_conan selector_spread_wixoss hetalia yowamushi_pedal hajime_no_ippo yozakura_quartet tiger_bunny brave_witches idolmaster inuyasha lupin_iii osomatsu_san tsubasa baki dragon_ball gatchaman ginga_tetsudou sengoku_basara minami_ke ikkitousen tegamibachi aria genshiken slayers dog_days cardcaptor_sakura school_rumble black_jack uchuu_senkan_yamato diamond_no_ace hayate_no_gotoku hokuto_no_ken hack aa_megami_sama uchuu_kyoudai aquarion koneko_no_chi mahou_shoujo_lyrical_nanoha yuu_yuu_hakusho cardfight_vanguard slam_dunk baku_tech_bakugan saint_seiya binan_koukou_chikyuu_boueibu_love kiniro_no_corda queen_s_blade saiyuki major yu_gi_oh tennis_no_ouji_sama teekyuu mobile_police_patlabor gegege_no_kitarou senki_zesshou_symphogear city_hunter soukyuu_no_fafner toriko marvel ookiku_furikabutte urusei_yatsura pripara aikatsu inazuma_eleven pretty_cure maria_sama digimon fushigi_yuugi saki tamayura glass_no_kamen d_c mai_hime angelique ranma ad_police taiho_shichau_zo seikai_no_senki kimagure_orange_road hidamari_sketch mazinkaiser cutey_honey beyblade futari_wa_milky_holmes time_bokan kindaichi_shounen_no_jikenbo cyborg doraemon votoms_finder captain_tsubasa transformers to_heart sakura_taisen dirty_pair space_cobra konjiki_no_gash_bell el_hazard saber_marionette_j di_gi_charat galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        hiroyuki_imaishi tensai_okamura yoshiaki_kawajiri shinichiro_watanabe makoto_shinkai gen_urobuchi hayao_miyazaki key mamoru_hosoda clamp kunihiko_ikuhara hideaki_anno type_moon shoji_kawamori kenji_nakamura masaaki_yuasa mamoru_oshii isao_takahata kouji_morimoto kenji_kamiyama masamune_shirow shinji_aramaki satoshi_kon rintaro go_nagai osamu_tezuka kouichi_mashimo ryousuke_takahashi naoki_urasawa katsuhiro_otomo nobuo_uematsu yoshiyuki_tomino rumiko_takahashi yoshitaka_amano osamu_dezaki nobuyuki_fukumoto kunihiko_yuyama leiji_matsumoto yoshikazu_yasuhiko tomoharu_katsumata shoutarou_ishinomori masami_kurumada satoshi_dezaki mitsuteru_yokoyama
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
