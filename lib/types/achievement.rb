module Types
  module Achievement
    NEKO_GROUPS = %i[common genre franchise]
    NekoGroup = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_GROUPS)

    # rubocop:disable LineLength
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

        action
        drama
        horror_thriller
        josei
        kids
        military
        mystery
        police
        seinen
        space
        sports

        music
      ],
      NekoGroup[:franchise] => %i[
        naruto nasuverse shingeki_no_kyojin bakemonogatari sword_art_online kuroko_no_basket code_geass boku_no_hero_academia high_school_dxd kuroshitsuji fairy_tail fullmetal_alchemist shokugeki_no_souma gintama nanatsu_no_taizai durarara haikyuu koro_sensei_q one_piece zero_no_tsukaima jojo_no_kimyou_na_bouken ghost_in_the_shell suzumiya_haruhi_no_yuuutsu bleach natsume_yuujinchou to_love_ru berserk toaru_majutsu_no_index junjou_romantica bakuman when_they_cry magi pokemon free clannad hunter_x_hunter love_live mushishi sailor_moon full_metal_panic gundam initial_d tales_of shakugan_no_shana working uta_no_prince_sama detective_conan dragon_ball rurouni_kenshin hajime_no_ippo hetalia persona nurarihyon_no_mago blood amagami_ss major slayers yowamushi_pedal jigoku_shoujo ushio_to_tora macross amon lupin_iii inuyasha negima tenchi_muyou ikkitousen minami_ke tennis_no_ouji_sama garo megalo_box tsubasa aa_megami_sama eureka_seven utawarerumono selector_spread_wixoss genshiken idolmaster dmatsu_san hayate_no_gotoku ginga_tetsudou sengoku_basara cardcaptor_sakura zettai_karen_children baki sket_dance hack school_rumble tegamibachi diamond_no_ace aquarion_evol gatchaman ginga_eiyuu_densetsu aria_the_origination hikaru_no_go black_jack koneko_no_chi pretty_cure mahou_shoujo_lyrical_nanoha queen_s_blade saint_seiya cardfight_vanguard inazuma_eleven yu_gi_oh hokuto_no_ken uchuu_senkan_yamato sonic digimon_savers slam_dunk saiyuuki_gaiden angelique senki_zesshou_symphogear d_c ranma fushigi_yuugi hidamari_sketch mai_hime iron_man yuu_yuu_hakusho saki soukyuu_no_fafner mobile_police_patlabor toriko uchuu_kyoudai doraemon transformers city_hunter glass_no_kamen taiho_shichau_zo pripara aikatsu urusei_yatsura futari_wa_milky_holmes votoms_finder ad_police maison_ikkoku kimagure_orange_road muumin to_heart candy_candy cyborg kindaichi_shounen_no_jikenbo sakura_taisen ehon_yose time_bokan cutey_honey mazinkaiser galaxy_angel space_cobra dirty_pair di_gi_charat el_hazard saber_marionette_j konjiki_no_gash_bell touch mahoujin_guruguru grendizer_giga tiger_mask captain_tsubasa getter_robo ojamajo_doremi super_robot_taisen_og kinnikuman rean_no_tsubasa zoids choujuu_kishin_dancougar ultraman dragon_quest mahou_no_princess_minky_momo juusenki_l_gaim super_doll_licca_chan haou_daikei_ryuu_knight obake_no_q_tarou pro_golfer_saru ginga_senpuu_braiger
      ]
    }
    # rubocop:enable LineLength
    INVERTED_NEKO_IDS = NEKO_IDS.each_with_object({}) do |(group, ids), memo|
      ids.each { |id| memo[id] = NekoGroup[group] }
    end
    ORDERED_NEKO_IDS = INVERTED_NEKO_IDS.keys

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ORDERED_NEKO_IDS)
  end
end
