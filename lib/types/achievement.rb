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
        shingeki_no_kyojin sword_art_online tokyo_ghoul science_adventure fullmetal_alchemist naruto ao_no_exorcist boku_no_hero_academia code_geass bakemonogatari nanatsu_no_taizai fate overlord fairy_tail durarara ansatsu_kyoushitsu darker_than_black kuroshitsuji chuunibyou_demo_koi_ga_shitai shokugeki_no_souma suzumiya_haruhi_no_yuuutsu evangelion kuroko_no_basket high_school_dxd kamisama_hajimemashita bleach k_on hellsing danganronpa k haikyuu when_they_cry jojo_no_kimyou_na_bouken toaru_majutsu_no_index ghost_in_the_shell gintama magi clannad berserk nisekoi hunter_x_hunter bakuman ore_no_imouto zero_no_tsukaima one_piece natsume_yuujinchou mushishi free to_love_ru tales_of full_metal_panic kara_no_kyoukai kami_nomi_zo_shiru_sekai blood persona jigoku_shoujo seitokai_yakuindomo love_live sora_no_otoshimono devilman working arslan_senki rurouni_kenshin sayonara_zetsubou_sensei shakugan_no_shana xxxholic amagami_ss hibike_euphonium eureka_seven ashita_no_joe nurarihyon_no_mago junjou_romantica rozen_maiden hoozuki_no_reitetsu ushio_to_tora chihayafuru hakuouki gundam garo sailor_moon yuru_yuri uta_no_prince_sama negima little_busters nodame_cantabile macross pokemon selector_spread_wixoss tenchi_muyou yowamushi_pedal utawarerumono idolmaster hetalia detective_conan initial_d hajime_no_ippo ginga_eiyuu_densetsu brave_witches yozakura_quartet tiger_bunny inuyasha osomatsu_san tsubasa gatchaman lupin_iii ginga_tetsudou sengoku_basara dragon_ball tegamibachi minami_ke baki aria cardcaptor_sakura dog_days genshiken slayers school_rumble black_jack hayate_no_gotoku uchuu_senkan_yamato ikkitousen hack aquarion aa_megami_sama hokuto_no_ken diamond_no_ace uchuu_kyoudai koneko_no_chi mahou_shoujo_lyrical_nanoha cardfight_vanguard yuu_yuu_hakusho slam_dunk binan_koukou_chikyuu_boueibu_love saiyuki kiniro_no_corda saint_seiya queen_s_blade major tennis_no_ouji_sama baku_tech_bakugan teekyuu yu_gi_oh senki_zesshou_symphogear mobile_police_patlabor ookiku_furikabutte toriko soukyuu_no_fafner marvel gegege_no_kitarou digimon aikatsu pretty_cure saki pripara inazuma_eleven urusei_yatsura fushigi_yuugi tamayura glass_no_kamen maria_sama angelique city_hunter d_c mai_hime ranma ad_police seikai_no_senki hidamari_sketch cutey_honey kimagure_orange_road time_bokan taiho_shichau_zo beyblade futari_wa_milky_holmes mazinkaiser kindaichi_shounen_no_jikenbo cyborg votoms_finder doraemon captain_tsubasa sakura_taisen to_heart transformers dirty_pair space_cobra konjiki_no_gash_bell el_hazard saber_marionette_j galaxy_angel di_gi_charat haou_daikei_ryuu_knight
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
