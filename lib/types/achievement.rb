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
        otaku
        fujoshi
        yuuri

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
        fullmetal_alchemist gintama ginga_eiyuu_densetsu hunter_x_hunter hanamonogatari haikyuu code_geass mushishi rurouni_kenshin natsume_yuujinchou suzumiya_haruhi_no_yuuutsu bakuman fate_zero jojo_no_kimyou_na_bouken aria_the_ova ghost_in_the_shell kuroko_no_basket shokugeki_no_souma major detective_conan evangelion berserk magi cyborg diamond_no_ace tsubasa umineko_no_naku_koro_ni one_piece inuyasha gundam initial_d katekyo_hitman_reborn durarara working cardcaptor_sakura saint_seiya junjou_romantica chiba_pedal hybrid_deka lupin_iii boruto eureka_seven full_metal_panic fairy_tail persona new_game slayers toaru_majutsu_no_index city_hunter kindaichi_shounen_no_jikenbo snow_halation prince_of_tennis sword_art_online amon macross jigoku_shoujo tenchi_muyou muumin saiyuuki_gaiden moon_pride digimon_savers hokuto_no_ken mahoujin_guruguru nen_joou seikai_no_senki votoms_finder bleach mazinkaiser pokemon urusei_yatsura yes_precure yes_precure hetalia tegamibachi hayate_no_gotoku mobile_police_patlabor ranma atom genshiken to_love_ru space_cobra negima getter_robo minami_ke garo blood kimagure_orange_road pripara utawarerumono shakugan_no_shana soukyuu_no_fafner puchimas zero_no_tsukaima aa_megami_sama senki_zesshou_symphogear zettai_karen_children saki casshern taiho_shichau_zo yu_gi_oh mai_hime force_live captain_tsubasa tiger_mask saber_marionette_j galaxy_angel phi_brain ad_police d_c kinnikuman hack_gift futari_wa_milky_holmes aquarion_evol dr_slump di_gi_charat dirty_pair mahou_no_yousei_persia angelique ginga_senpuu_braiger ikkitousen queen_s_blade ultraman obake_no_q_tarou pro_golfer_saru
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
