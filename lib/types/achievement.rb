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
        shingeki_no_kyojin sword_art_online tokyo_ghoul science_adventure fullmetal_alchemist boku_no_hero_academia naruto ao_no_exorcist nanatsu_no_taizai code_geass psycho_pass bakemonogatari overlord fate ansatsu_kyoushitsu fairy_tail bungou_stray_dogs danmachi durarara darker_than_black kuroshitsuji shokugeki_no_souma chuunibyou_demo_koi_ga_shitai evangelion jojo_no_kimyou_na_bouken suzumiya_haruhi_no_yuuutsu kuroko_no_basket high_school_dxd bleach kamisama_hajimemashita hellsing k_on danganronpa haikyuu when_they_cry toaru_majutsu_no_index date_a_live k hunter_x_hunter ghost_in_the_shell berserk gintama black_lagoon clannad magi one_piece nisekoi bakuman zero_no_tsukaima natsume_yuujinchou mushishi ore_no_imouto strike_the_blood saiki_kusuo_no_nan shingeki_no_bahamut to_love_ru free devilman full_metal_panic tales_of kara_no_kyoukai kami_nomi_zo_shiru_sekai blood seitokai_yakuindomo jigoku_shoujo love_live rurouni_kenshin sora_no_otoshimono persona working arslan_senki sayonara_zetsubou_sensei hibike_euphonium xxxholic amagami_ss shakugan_no_shana ashita_no_joe nurarihyon_no_mago chihayafuru rozen_maiden junjou_romantica sailor_moon hoozuki_no_reitetsu ushio_to_tora yuru_yuri eureka_seven negima gundam hakuouki garo pokemon uta_no_prince_sama ginga_eiyuu_densetsu nodame_cantabile little_busters initial_d macross tenchi_muyou utawarerumono detective_conan hajime_no_ippo hetalia selector_spread_wixoss yozakura_quartet brave_witches inuyasha yowamushi_pedal tiger_bunny lupin_iii idolmaster dragon_ball osomatsu_san baki tsubasa ginga_tetsudou gatchaman sengoku_basara minami_ke aria tegamibachi ikkitousen slayers genshiken cardcaptor_sakura dog_days diamond_no_ace school_rumble black_jack uchuu_senkan_yamato hokuto_no_ken hayate_no_gotoku hack uchuu_kyoudai aa_megami_sama baku_tech_bakugan yuu_yuu_hakusho slam_dunk aquarion koneko_no_chi mahou_shoujo_lyrical_nanoha senki_zesshou_symphogear cardfight_vanguard saint_seiya queen_s_blade kiniro_no_corda yu_gi_oh binan_koukou_chikyuu_boueibu_love saiyuki major tennis_no_ouji_sama mobile_police_patlabor teekyuu gegege_no_kitarou city_hunter starmyu soukyuu_no_fafner urusei_yatsura toriko pripara marvel ookiku_furikabutte aikatsu inazuma_eleven pretty_cure maria_sama digimon fushigi_yuugi tamayura saki glass_no_kamen taiho_shichau_zo ad_police ranma d_c mai_hime angelique seikai_no_senki kimagure_orange_road hidamari_sketch cutey_honey mazinkaiser beyblade futari_wa_milky_holmes time_bokan kindaichi_shounen_no_jikenbo koihime_musou votoms_finder cyborg doraemon transformers captain_tsubasa to_heart sakura_taisen dirty_pair space_cobra konjiki_no_gash_bell el_hazard stitch saber_marionette_j di_gi_charat galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hiroshi_hamasaki makoto_shinkai hiroyuki_imaishi akiyuki_shinbou hayao_miyazaki gen_urobuchi key takahiro_oomori yasuhiro_takemoto shinichiro_watanabe chiaki_kon type_moon hideaki_anno mamoru_hosoda morio_asaka shoji_kawamori osamu_tezuka isao_takahata kenji_kamiyama masamune_shirow mamoru_oshii kouji_morimoto masaaki_yuasa clamp satoshi_kon yoshiaki_kawajiri kenji_nakamura shinji_aramaki junichi_satou kouichi_mashimo go_nagai kunihiko_ikuhara katsuhiro_otomo rumiko_takahashi osamu_dezaki yoshitaka_amano yoshiyuki_tomino leiji_matsumoto rintaro ryousuke_takahashi toshio_maeda
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
