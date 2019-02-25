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
        sword_art_online shingeki_no_kyojin tokyo_ghoul science_adventure fullmetal_alchemist naruto ao_no_exorcist boku_no_hero_academia code_geass bakemonogatari nanatsu_no_taizai overlord fairy_tail fate durarara ansatsu_kyoushitsu darker_than_black kuroshitsuji chuunibyou_demo_koi_ga_shitai shokugeki_no_souma evangelion suzumiya_haruhi_no_yuuutsu kuroko_no_basket high_school_dxd kamisama_hajimemashita bleach k_on hellsing danganronpa jojo_no_kimyou_na_bouken k when_they_cry haikyuu toaru_majutsu_no_index ghost_in_the_shell gintama berserk magi clannad hunter_x_hunter nisekoi bakuman one_piece zero_no_tsukaima natsume_yuujinchou ore_no_imouto mushishi free to_love_ru tales_of full_metal_panic kara_no_kyoukai kami_nomi_zo_shiru_sekai blood devilman seitokai_yakuindomo persona jigoku_shoujo love_live sora_no_otoshimono rurouni_kenshin working arslan_senki sayonara_zetsubou_sensei xxxholic shakugan_no_shana amagami_ss hibike_euphonium ashita_no_joe nurarihyon_no_mago eureka_seven rozen_maiden junjou_romantica hoozuki_no_reitetsu ushio_to_tora chihayafuru sailor_moon hakuouki yuru_yuri negima garo gundam uta_no_prince_sama nodame_cantabile little_busters macross pokemon tenchi_muyou selector_spread_wixoss utawarerumono yowamushi_pedal initial_d hetalia detective_conan idolmaster ginga_eiyuu_densetsu hajime_no_ippo tiger_bunny yozakura_quartet brave_witches inuyasha lupin_iii osomatsu_san tsubasa gatchaman baki dragon_ball ginga_tetsudou sengoku_basara tegamibachi minami_ke ikkitousen aria slayers cardcaptor_sakura dog_days genshiken school_rumble black_jack uchuu_senkan_yamato hayate_no_gotoku hack hokuto_no_ken aa_megami_sama aquarion uchuu_kyoudai diamond_no_ace koneko_no_chi mahou_shoujo_lyrical_nanoha cardfight_vanguard yuu_yuu_hakusho slam_dunk binan_koukou_chikyuu_boueibu_love saint_seiya baku_tech_bakugan saiyuki kiniro_no_corda queen_s_blade tennis_no_ouji_sama major teekyuu yu_gi_oh senki_zesshou_symphogear gegege_no_kitarou mobile_police_patlabor city_hunter toriko ookiku_furikabutte marvel urusei_yatsura soukyuu_no_fafner pretty_cure aikatsu inazuma_eleven digimon maria_sama saki fushigi_yuugi pripara tamayura glass_no_kamen d_c angelique mai_hime ranma ad_police seikai_no_senki kimagure_orange_road taiho_shichau_zo hidamari_sketch cutey_honey futari_wa_milky_holmes time_bokan beyblade kindaichi_shounen_no_jikenbo mazinkaiser cyborg votoms_finder doraemon captain_tsubasa to_heart transformers sakura_taisen dirty_pair space_cobra konjiki_no_gash_bell el_hazard saber_marionette_j galaxy_angel di_gi_charat haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        hiroyuki_imaishi tensai_okamura yoshiaki_kawajiri shinichiro_watanabe makoto_shinkai gen_urobuchi hayao_miyazaki key mamoru_hosoda clamp kunihiko_ikuhara hideaki_anno type_moon shoji_kawamori kenji_nakamura masaaki_yuasa mamoru_oshii isao_takahata kouji_morimoto kenji_kamiyama masamune_shirow shinji_aramaki satoshi_kon rintaro go_nagai osamu_tezuka kouichi_mashimo ryousuke_takahashi naoki_urasawa katsuhiro_otomo nobuo_uematsu yoshiyuki_tomino rumiko_takahashi yoshitaka_amano osamu_dezaki nobuyuki_fukumoto kunihiko_yuyama leiji_matsumoto yoshikazu_yasuhiko tomoharu_katsumata shoutarou_ishinomori masami_kurumada satoshi_dezaki mitsuteru_yokoyama hiroshi_motomiya osamu_kobayashi
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
