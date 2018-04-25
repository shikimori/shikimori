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
        fullmetal_alchemist gintama ginga_eiyuu_densetsu hunter_x_hunter hanamonogatari code_geass mushishi rurouni_kenshin natsume_yuujinchou suzumiya_haruhi_no_yuuutsu bakuman fate_zero jojo_no_kimyou_na_bouken aria_the_ova ghost_in_the_shell kuroko_no_basket major magic_kaito evangelion umineko_no_naku_koro_ni one_piece inuyasha gundam dr_slump initial_d durarara working saint_seiya junjou_romantica lupin_iii full_metal_panic boruto fairy_tail new_game persona slayers toaru_majutsu_no_index city_hunter prince_of_tennis jigoku_shoujo macross sasami saiyuuki_gaiden moon_pride digimon_savers hokuto_no_ken nen_joou seikai_no_senki votoms_finder bleach pokemon yes_precure hetalia hayate_no_gotoku mobile_police_patlabor ranma atom to_love_ru genshiken minami_ke blood shakugan_no_shana zero_no_tsukaima saki taiho_shichau_zo yu_gi_oh captain_tsubasa galaxy_angel phi_brain ad_police d_c hack_gift futari_wa_milky_holmes dirty_pair ikkitousen queen_s_blade shokugeki_no_souma diamond_no_ace chiba_pedal haikyuu urusei_yatsura casshern amon berserk space_cobra mazinkaiser muumin re getter_robo ultraman kimagure_orange_road kinnikuman tiger_mask ginga_senpuu_braiger mahou_no_yousei_persia obake_no_q_tarou pro_golfer_saru mahoujin_guruguru force_live aa_megami_sama cardcaptor_sakura mai_hime tsubasa utawarerumono zettai_karen_children di_gi_charat hybrid_deka senki_zesshou_symphogear soukyuu_no_fafner aquarion_evol sword_art_online tegamibachi eureka_seven garo puchimas ldlive kindaichi_shounen_no_jikenbo snow_halation magi negima angelique pripara saber_marionette_j yes_precure
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
