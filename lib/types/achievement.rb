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
        fullmetal_alchemist gintama ginga_eiyuu_densetsu hunter_x_hunter clannad hanamonogatari haikyuu code_geass mushishi hajime_no_ippo rurouni_kenshin boku_no_hero_academia natsume_yuujinchou suzumiya_haruhi_no_yuuutsu bakuman fate_zero koro_sensei_q jojo_no_kimyou_na_bouken megalo_box aria_the_ova ghost_in_the_shell slam_dunk uchuu_kyoudai kuroko_no_basket kuroshitsuji major shokugeki_no_souma shingeki_no_kyojin yuu_yuu_hakusho detective_conan gundam yamato berserk magi diamond_no_ace tsubasa nanatsu_no_taizai umineko_no_naku_koro_ni one_piece sket_dance inuyasha dragon_ball initial_d cardcaptor_sakura durarara working saint_seiya vivid_strike maison_ikkoku chiba_pedal junjou_romantica lupin_iii glass_no_kamen boruto hikaru_no_go dmatsu_san eureka_seven full_metal_panic fairy_tail hidamari_sketch persona doraemon toaru_majutsu_no_index kindaichi_shounen_no_jikenbo school_rumble slayers tennis_no_ouji_sama city_hunter snow_halation nurarihyon_no_mago touch sword_art_online muumin ushio_to_tora jigoku_shoujo macross amon tenchi_muyou saiyuuki_gaiden moon_pride hokuto_no_ken nen_joou mahoujin_guruguru digimon_savers votoms_finder bleach mazinkaiser transformers pokemon yes_precure urusei_yatsura koneko_no_chii tegamibachi hayate_no_gotoku hetalia ranma black_jack mobile_police_patlabor genshiken to_love_ru space_cobra aikatsu high_school_dxd ojamajo_doremi getter_robo garo negima minami_ke blood fushigi_yuugi kimagure_orange_road pripara dragon_quest utawarerumono shakugan_no_shana tales_of_gekijou soukyuu_no_fafner puchimas zero_no_tsukaima toriko locker_room aa_megami_sama senki_zesshou_symphogear grendizer_giga zettai_karen_children konjiki_no_gash_bell saki casshern candy_candy taiho_shichau_zo yu_gi_oh seiren mai_hime selector_spread_wixoss captain_tsubasa force_live zoids baki tiger_mask saber_marionette_j el_hazard galaxy_angel cardfight_vanguard cyborg rean_no_tsubasa gall_force d_c kinnikuman super_robot_taisen_og hack_gift aquarion_evol futari_wa_milky_holmes di_gi_charat dirty_pair angelique cutey_honey mahou_no_princess_minky_momo ehon_yose to_heart sakura_taisen ginga_senpuu_braiger ikkitousen juusenki_l_gaim sonic believe choujuu_kishin_dancougar queen_s_blade haou_daikei_ryuu_knight super_doll_licca_chan ultraman iron_man obake_no_q_tarou pro_golfer_saru
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
