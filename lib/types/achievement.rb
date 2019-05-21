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
        sword_art_online shingeki_no_kyojin tokyo_ghoul science_adventure fullmetal_alchemist naruto boku_no_hero_academia ao_no_exorcist code_geass bakemonogatari nanatsu_no_taizai overlord fairy_tail fate ansatsu_kyoushitsu durarara darker_than_black kuroshitsuji chuunibyou_demo_koi_ga_shitai shokugeki_no_souma evangelion suzumiya_haruhi_no_yuuutsu kuroko_no_basket high_school_dxd kamisama_hajimemashita bleach jojo_no_kimyou_na_bouken hellsing k_on danganronpa k when_they_cry haikyuu toaru_majutsu_no_index date_a_live ghost_in_the_shell gintama berserk magi clannad hunter_x_hunter nisekoi bakuman one_piece natsume_yuujinchou zero_no_tsukaima mushishi shingeki_no_bahamut free to_love_ru tales_of full_metal_panic kara_no_kyoukai kami_nomi_zo_shiru_sekai devilman blood seitokai_yakuindomo persona jigoku_shoujo love_live sora_no_otoshimono rurouni_kenshin working arslan_senki sayonara_zetsubou_sensei xxxholic shakugan_no_shana amagami_ss hibike_euphonium ashita_no_joe nurarihyon_no_mago rozen_maiden eureka_seven junjou_romantica hoozuki_no_reitetsu chihayafuru ushio_to_tora sailor_moon hakuouki negima yuru_yuri gundam garo uta_no_prince_sama nodame_cantabile little_busters macross pokemon tenchi_muyou initial_d selector_spread_wixoss utawarerumono yowamushi_pedal hetalia ginga_eiyuu_densetsu detective_conan idolmaster hajime_no_ippo tiger_bunny yozakura_quartet brave_witches inuyasha lupin_iii osomatsu_san tsubasa baki gatchaman dragon_ball ginga_tetsudou sengoku_basara ikkitousen tegamibachi minami_ke aria slayers dog_days cardcaptor_sakura genshiken school_rumble black_jack uchuu_senkan_yamato hayate_no_gotoku hack hokuto_no_ken aa_megami_sama aquarion uchuu_kyoudai diamond_no_ace koneko_no_chi mahou_shoujo_lyrical_nanoha cardfight_vanguard yuu_yuu_hakusho slam_dunk baku_tech_bakugan saint_seiya binan_koukou_chikyuu_boueibu_love saiyuki kiniro_no_corda queen_s_blade tennis_no_ouji_sama major yu_gi_oh teekyuu senki_zesshou_symphogear mobile_police_patlabor gegege_no_kitarou city_hunter toriko ookiku_furikabutte marvel urusei_yatsura soukyuu_no_fafner pretty_cure aikatsu inazuma_eleven pripara digimon maria_sama fushigi_yuugi saki tamayura glass_no_kamen d_c angelique mai_hime ranma ad_police seikai_no_senki taiho_shichau_zo kimagure_orange_road hidamari_sketch cutey_honey futari_wa_milky_holmes time_bokan beyblade kindaichi_shounen_no_jikenbo mazinkaiser cyborg votoms_finder doraemon captain_tsubasa transformers to_heart sakura_taisen dirty_pair space_cobra konjiki_no_gash_bell el_hazard saber_marionette_j di_gi_charat galaxy_angel haou_daikei_ryuu_knight
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
