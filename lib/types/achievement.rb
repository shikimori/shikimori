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
        fullmetal_alchemist gintama ginga_eiyuu_densetsu hunter_x_hunter hanamonogatari haikyuu code_geass mushishi hajime_no_ippo rurouni_kenshin boku_no_hero_academia natsume_yuujinchou suzumiya_haruhi_no_yuuutsu bakuman koro_sensei_q fate_zero jojo_no_kimyou_na_bouken aria_the_ova megalo_box kuroshitsuji uchuu_kyoudai ghost_in_the_shell kuroko_no_basket shokugeki_no_souma slam_dunk major detective_conan yuu_yuu_hakusho yamato berserk magi diamond_no_ace tsubasa umineko_no_naku_koro_ni one_piece inuyasha sket_dance gundam dragon_ball initial_d durarara working cardcaptor_sakura nanatsu_no_taizai saint_seiya vivid_strike maison_ikkoku junjou_romantica chiba_pedal glass_no_kamen lupin_iii dmatsu_san hikaru_no_go boruto eureka_seven full_metal_panic fairy_tail persona hidamari_sketch slayers doraemon toaru_majutsu_no_index city_hunter kindaichi_shounen_no_jikenbo snow_halation nurarihyon_no_mago tennis_no_ouji_sama school_rumble touch sword_art_online amon ushio_to_tora macross jigoku_shoujo tenchi_muyou muumin saiyuuki_gaiden moon_pride digimon_savers hokuto_no_ken mahoujin_guruguru nen_joou votoms_finder bleach mazinkaiser transformers pokemon urusei_yatsura yes_precure hetalia tegamibachi hayate_no_gotoku mobile_police_patlabor ranma black_jack genshiken to_love_ru space_cobra aikatsu negima getter_robo minami_ke ojamajo_doremi garo blood kimagure_orange_road dragon_quest fushigi_yuugi pripara utawarerumono shakugan_no_shana soukyuu_no_fafner puchimas zero_no_tsukaima toriko aa_megami_sama locker_room senki_zesshou_symphogear grendizer_giga zettai_karen_children konjiki_no_gash_bell saki casshern candy_candy taiho_shichau_zo yu_gi_oh seiren mai_hime selector_spread_wixoss baki force_live captain_tsubasa tiger_mask saber_marionette_j el_hazard galaxy_angel cardfight_vanguard cyborg rean_no_tsubasa gall_force d_c kinnikuman super_robot_taisen_og hack_gift futari_wa_milky_holmes aquarion_evol di_gi_charat dirty_pair angelique cutey_honey mahou_no_princess_minky_momo ehon_yose to_heart sakura_taisen ginga_senpuu_braiger ikkitousen juusenki_l_gaim sonic choujuu_kishin_dancougar queen_s_blade haou_daikei_ryuu_knight super_doll_licca_chan ultraman iron_man obake_no_q_tarou pro_golfer_saru
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
