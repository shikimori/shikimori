# rubocop:disable all
# модель для сбора id аниме и манги, заблокированных требованиями копирайта
module Copyright
  # by Hetzner abuse team
  ANIME_SCREENSHOTS = [28215, 23587]
  ANIME_VIDEOS = ANIME_SCREENSHOTS

  # by Hetzner abuse team
  MANGA_IDS = [1]

  # taken from https://shikimori.one/collections/6269-zapreschyonnye-anime
  # CollectionLink.where(collection_id: 6269).pluck(:linked_id).sort.uniq.each {|v| puts "    #{v}, # #{Anime.find(v).name}" };
  CENSORED_IN_RUSSIA_ANIME_IDS = [
    20, # Naruto
    21, # One Piece
    47, # Akira
    226, # Elfen Lied
    235, # Detective Conan
    257, # Ikkitousen
    356, # Fate/stay night
    379, # Heppoko Jikken Animation Excel♥Saga
    487, # Girls Bravo: Second Season
    501, # Doraemon
    527, # Pokemon
    530, # Bishoujo Senshi Sailor Moon
    552, # Digimon Adventure
    564, # Puni Puni☆Poemii
    578, # Hotaru no Haka
    790, # Ergo Proxy
    818, # Sakura Tsuushin
    934, # Higurashi no Naku Koro ni
    966, # Crayon Shin-chan
    1045, # Elf wo Karu Mono-tachi
    1292, # Afro Samurai
    1535, # Death Note
    1629, # Devilman Lady
    1726, # Devil May Cry
    1818, # Claymore
    2025, # Darker than Black: Kuro no Keiyakusha
    2161, # Skull Man
    2167, # Clannad
    2403, # Kodomo no Jikan (TV)
    2476, # School Days
    3272, # Kinnikuman
    3342, # Mnemosyne: Mnemosyne no Musume-tachi
    3444, # The☆Ultraman
    3455, # To LOVE-Ru
    3503, # Kanokon
    4138, # Chiisana Penguin Lolo no Bouken
    4898, # Kuroshitsuji
    5060, # Hetalia Axis Powers
    5081, # Bakemonogatari
    5680, # K-On!
    6201, # Princess Lover!
    6500, # Seikon no Qwaser
    6547, # Angel Beats!
    6746, # Durarara!!
    6747, # Dance in the Vampire Bund
    6880, # Deadman Wonderland
    6987, # Aki-Sora
    7088, # Ichiban Ushiro no Daimaou
    7148, # Ladies versus Butlers!
    8074, # Highschool of the Dead
    8277, # Hyakka Ryouran: Samurai Girls
    8861, # Yosuga no Sora: In Solitude, Where We Are Least Alone.
    9367, # Freezing
    9756, # Mahou Shoujo Madoka★Magica
    10_278, # The iDOLM@STER
    10_465, # Manyuu Hikenchou
    10_490, # Blood-C
    10_611, # R-15
    10_721, # Mawaru Penguindrum
    11_111, # Another
    11_617, # High School DxD
    11_757, # Sword Art Online
    12_549, # Dakara Boku wa, H ga Dekinai.
    13_161, # Hagure Yuusha no Aesthetica
    13_601, # Psycho-Pass
    13_759, # Sakura-sou no Pet na Kanojo
    13_807, # Corpse Party: Missing Footage
    14_813, # Yahari Ore no Seishun Love Comedy wa Machigatteiru.
    14_829, # Fate/kaleid liner Prisma☆Illya
    14_833, # Maoyuu Maou Yuusha
    15_051, # Love Live! School Idol Project
    15_583, # Date A Live
    16_011, # Tokyo Ravens
    16_498, # Shingeki no Kyojin
    16_774, # Inferno Cop
    17_729, # Grisaia no Kajitsu
    17_827, # Daitoshokan no Hitsujikai
    18_153, # Kyoukai no Kanata
    18_277, # Strike the Blood
    18_507, # Free!
    18_679, # Kill la Kill
    19_221, # Ore no Nounai Sentakushi ga, Gakuen Love Comedy wo Zenryoku de Jama Shiteiru
    19_315, # Pupa
    19_383, # Yami Shibai
    19_429, # Akuma no Riddle
    19_815, # No Game No Life
    20_033, # Miss Monochrome The Animation
    21_033, # Seikoku no Dragonar
    21_353, # Tokyo ESP
    21_511, # Kantai Collection: KanColle
    22_199, # Akame ga Kill!
    22_319, # Tokyo Ghoul
    22_535, # Kiseijuu: Sei no Kakuritsu
    22_663, # Seiken Tsukai no World Break
    22_729, # Aldnoah.Zero
    22_865, # Rokujouma no Shinryakusha!? (TV)
    22_877, # Seireitsukai no Blade Dance
    23_209, # Sora no Method
    23_233, # Shinmai Maou no Testament
    23_277, # Saenai Heroine no Sodatekata
    23_283, # Zankyou no Terror
    23_673, # Ookami Shoujo to Kuro Ouji
    23_755, # Nanatsu no Taizai
    24_455, # Madan no Ou to Vanadis
    24_629, # Koufuku Graffiti
    24_833, # Ansatsu Kyoushitsu
    24_873, # Juuou Mujin no Fafnir
    25_157, # Trinity Seven
    25_397, # Absolute Duo
    30_831, # Kono Subarashii Sekai ni Shukufuku wo!
    31_174, # Osomatsu-san
    31_478, # Bungou Stray Dogs
    32_615, # Youjo Senki
    34_019, # Tsugumomo
    34_177, # Tenshi no 3P!
    34_542, # Inuyashiki
    34_658, # Nekopara OVA
    35_241, # Konohana Kitan
    35_849, # Darling in the FranXX
    35_994, # Satsuriku no Tenshi
    36_632, # Ore ga Suki nano wa Imouto dakedo Imouto ja Nai
    37_055, # Youjo Senki Movie
    37_210, # Isekai Maou to Shoukan Shoujo no Dorei Majutsu
    37_349, # Goblin Slayer
    37_430, # Tensei shitara Slime Datta Ken
    37_517, # Happy Sugar Life
    37_976, # Zombieland Saga
    37_998, # Girly Air Force
    38_397, # Nande Koko ni Sensei ga!?
    38_656, # Darwin's Game
    39_017, # Kyokou Suiri
    39_535, # Mushoku Tensei: Isekai Ittara Honki Dasu
    40_010, # Ishuzoku Reviewers
    40_046, # Id:Invaded
    40_750 # Kaifuku Jutsushi no Yarinaoshi
  ]
end
