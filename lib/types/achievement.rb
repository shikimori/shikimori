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
        fullmetal_alchemist gintama hunter_x_hunter ginga_eiyuu_densetsu hanamonogatari clannad haikyuu code_geass mushishi hajime_no_ippo rurouni_kenshin boku_no_hero_academia natsume_yuujinchou suzumiya_haruhi_no_yuuutsu bakuman koro_sensei_q fate_zero jojo_no_kimyou_na_bouken megalo_box aria_the_ova ghost_in_the_shell uchuu_kyoudai shokugeki_no_souma slam_dunk kuroko_no_basket major kuroshitsuji shingeki_no_kyojin yuu_yuu_hakusho detective_conan berserk gundam yamato magi diamond_no_ace tsubasa umineko_no_naku_koro_ni nanatsu_no_taizai inuyasha one_piece sket_dance dragon_ball initial_d cardcaptor_sakura durarara working vivid_strike saint_seiya maison_ikkoku chiba_pedal junjou_romantica glass_no_kamen lupin_iii boruto hikaru_no_go dmatsu_san eureka_seven full_metal_panic doraemon hidamari_sketch fairy_tail persona school_rumble slayers tennis_no_ouji_sama toaru_majutsu_no_index touch city_hunter kindaichi_shounen_no_jikenbo snow_halation nurarihyon_no_mago sword_art_online muumin ushio_to_tora macross jigoku_shoujo tenchi_muyou amon saiyuuki_gaiden moon_pride nen_joou hokuto_no_ken mahoujin_guruguru digimon_savers votoms_finder mazinkaiser transformers bleach pokemon yes_precure urusei_yatsura tegamibachi koneko_no_chii hayate_no_gotoku hetalia mobile_police_patlabor ranma black_jack genshiken to_love_ru space_cobra ojamajo_doremi high_school_dxd minami_ke blood getter_robo garo negima fushigi_yuugi kimagure_orange_road aikatsu utawarerumono dragon_quest pripara shakugan_no_shana tales_of_gekijou soukyuu_no_fafner puchimas zero_no_tsukaima toriko aa_megami_sama inazuma_eleven senki_zesshou_symphogear grendizer_giga zettai_karen_children konjiki_no_gash_bell saki candy_candy taiho_shichau_zo yu_gi_oh seiren mai_hime baki selector_spread_wixoss captain_tsubasa gatchaman zoids force_live saber_marionette_j tiger_mask el_hazard galaxy_angel cardfight_vanguard cyborg ad_police rean_no_tsubasa d_c kinnikuman super_robot_taisen_og hack_gift aquarion_evol futari_wa_milky_holmes dirty_pair di_gi_charat angelique cutey_honey mahou_no_princess_minky_momo ehon_yose to_heart sakura_taisen ikkitousen juusenki_l_gaim ginga_senpuu_braiger sonic believe choujuu_kishin_dancougar queen_s_blade haou_daikei_ryuu_knight super_doll_licca_chan ultraman iron_man obake_no_q_tarou pro_golfer_saru
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
