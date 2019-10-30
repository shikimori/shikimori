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
        shingeki_no_kyojin sword_art_online tokyo_ghoul science_adventure fullmetal_alchemist naruto boku_no_hero_academia ao_no_exorcist code_geass nanatsu_no_taizai bakemonogatari overlord fate fairy_tail ansatsu_kyoushitsu durarara danmachi bungou_stray_dogs darker_than_black kuroshitsuji chuunibyou_demo_koi_ga_shitai shokugeki_no_souma evangelion suzumiya_haruhi_no_yuuutsu jojo_no_kimyou_na_bouken kuroko_no_basket high_school_dxd bleach kamisama_hajimemashita hellsing k_on danganronpa haikyuu when_they_cry toaru_majutsu_no_index k date_a_live ghost_in_the_shell hunter_x_hunter berserk gintama black_lagoon clannad magi nisekoi one_piece bakuman zero_no_tsukaima natsume_yuujinchou mushishi ore_no_imouto saiki_kusuo_no_nan shingeki_no_bahamut to_love_ru free tales_of full_metal_panic devilman kara_no_kyoukai kami_nomi_zo_shiru_sekai blood seitokai_yakuindomo jigoku_shoujo love_live persona sora_no_otoshimono rurouni_kenshin working arslan_senki sayonara_zetsubou_sensei hibike_euphonium xxxholic amagami_ss shakugan_no_shana ashita_no_joe nurarihyon_no_mago rozen_maiden junjou_romantica chihayafuru sailor_moon hoozuki_no_reitetsu ushio_to_tora eureka_seven yuru_yuri negima hakuouki gundam garo uta_no_prince_sama pokemon nodame_cantabile little_busters ginga_eiyuu_densetsu initial_d macross tenchi_muyou detective_conan utawarerumono hajime_no_ippo hetalia selector_spread_wixoss yozakura_quartet brave_witches yowamushi_pedal tiger_bunny inuyasha idolmaster lupin_iii dragon_ball osomatsu_san baki tsubasa gatchaman ginga_tetsudou sengoku_basara minami_ke ikkitousen tegamibachi aria genshiken slayers cardcaptor_sakura dog_days school_rumble black_jack diamond_no_ace uchuu_senkan_yamato hokuto_no_ken hayate_no_gotoku hack aa_megami_sama uchuu_kyoudai aquarion yuu_yuu_hakusho koneko_no_chi baku_tech_bakugan slam_dunk mahou_shoujo_lyrical_nanoha cardfight_vanguard senki_zesshou_symphogear saint_seiya queen_s_blade binan_koukou_chikyuu_boueibu_love kiniro_no_corda yu_gi_oh saiyuki major tennis_no_ouji_sama teekyuu mobile_police_patlabor gegege_no_kitarou starmyu city_hunter urusei_yatsura soukyuu_no_fafner toriko pripara marvel aikatsu ookiku_furikabutte inazuma_eleven maria_sama pretty_cure digimon fushigi_yuugi tamayura saki glass_no_kamen d_c ranma ad_police mai_hime taiho_shichau_zo angelique seikai_no_senki kimagure_orange_road hidamari_sketch mazinkaiser cutey_honey beyblade futari_wa_milky_holmes time_bokan kindaichi_shounen_no_jikenbo koihime_musou votoms_finder cyborg doraemon captain_tsubasa transformers to_heart sakura_taisen dirty_pair space_cobra konjiki_no_gash_bell el_hazard saber_marionette_j di_gi_charat galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada makoto_shinkai hiroyuki_imaishi akiyuki_shinbou hayao_miyazaki gen_urobuchi key takahiro_oomori yasuhiro_takemoto shinichiro_watanabe chiaki_kon type_moon hideaki_anno shoji_kawamori mamoru_hosoda morio_asaka osamu_tezuka isao_takahata kenji_kamiyama masamune_shirow mamoru_oshii kouji_morimoto clamp masaaki_yuasa satoshi_kon yoshiaki_kawajiri kenji_nakamura shinji_aramaki junichi_satou kouichi_mashimo go_nagai ryousuke_takahashi kunihiko_ikuhara katsuhiro_otomo yoshiyuki_tomino rumiko_takahashi osamu_dezaki yoshitaka_amano leiji_matsumoto rintaro toshio_maeda
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
