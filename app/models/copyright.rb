# rubocop:disable all
# модель для сбора id аниме и манги, заблокированных требованиями копирайта
module Copyright
  # by Hetzner abuse team
  SCREENSHOTS = [28215, 23587]
  VIDEOS = SCREENSHOTS

  # http://www.daisuki.net/anime/
  DAISUKI_COPYRIGHTED = [
    27631, # God Eater
    28215, # Saint Seiya: Soul of Gold
    23587, # The iDOLM@STER Cinderella Girls
    29975, # Gunslinger StratosAniplex
    10937, # Mobile Suit Gundam: The Origin
    24415, # Kuroko no Basket 3rd Season
    16894, # Kuroko no Basket 2nd Season
    11771, # Kuroko no Basket
    10278, # The iDOLM@STER
    21881, # Sword Art Online II
    20021, # Sword Art Online: Extra Edition
    22145, # Kuroshitsuji: Book of Circus
    25049, # Sushi Ninja
    23133, # M3: Sono Kuroki Hagane
    21437, # Buddy Complex
    18679, # Kill la Kill
    20973, # World Conquest Zvezda Plot
  ]

  ISTARI_COPYRIGHTED = [
    # istari
    32281 # Kimi no Na wa
  ]
  VGTRK_COPYRIGHTED = [
    34541, # Mary to Majo no Hana
    34944 # Bungou Stray Dogs: Dead Apple
  ]
  CAPELLA_FILM_COPYRIGHTED = [
    # Capella Film
    33970, # Girls und Panzer das Finale
    35851, # Sayonara no Asa ni Yakusoku no Hana wo Kazarou
    10259, # Da hai
    37207 # Zuori Qing Kong
  ]
  EXPONENTA_COPYRIGHTED = [
    36936 # Mirai no Mirai
  ]
  PIONER_COPYRIGHTED = [
    # https://www.mos-gorsud.ru/mgs/defend/statementForm/80619321-6d78-4a51-8ca2-ae42d2c3c1ed
    199, # Spirited Away
    572, # Kaze no Tani no Nausicaa
  ]
  OTHER_COPYRIGHTED = [
    # письмо от post@webkontrol.ru на mail+copyright@shikimori.org
    # [Notice_ID:*IdOAQy*] Nintendo Company Ltd - Нарушение прав правообладателей / Nintendo Company Ltd - Abuse
    19157,
    # письмо от chelnakova@group-ib.ru на mail+copyright@shikimori.org
    28805, # Bakemono no ko
    # ООО "СИНЕМА ГАЛЭКСИ"
    # https://www.mos-gorsud.ru/mgs/defend/statementForm/d059c855-42f4-40a3-a6ec-930b5af44187
    23273, # Shigatsu wa Kimi no Uso
    28069, # Shigatsu wa Kimi no Uso: Moments
    28999, # Charlotte
    31553 # Charlotte: Tsuyoimono-tachi
  ] + EXPONENTA_COPYRIGHTED + PIONER_COPYRIGHTED + ISTARI_COPYRIGHTED + VGTRK_COPYRIGHTED + CAPELLA_FILM_COPYRIGHTED

  WAKANIM_COPYRIGHTED = [
    36144, # Garo: Vanishing Line | Russia + Eastern Europe 2017-10-01 - 2024-10-01
    35078, # Mitsuboshi Colors | Russia + Europe except Italy&Spanish 2018-08-01 - 2022-07-01
    33354, # Cardcaptor Sakura: Clear Card (Cardcaptor Sakura: Clear Card-hen) | Russia + French 2018-01-01 - 2025-12-31
    35320, # Cardcaptor Sakura: Clear Card Prologue (Cardcaptor Sakura: Clear Card-hen Prologue - Sakura to Futatsu no Kuma) | Russia + French 2018-01-01 - 2025-12-31
    35073, # Overlord II | Russia 2018-01-01 - 2022-01-01
    33478, # UQ Holder!: Mahou Sensei Negima! 2 | Russia 2017-10-01 - 2024-10-01
    36027, # King's Game The Animation (King's Game)| Russia + French 2017-10-01 - 2024-10-01
    35838, # Girls' Last Tour | Russia + French 2017-10-01 - 2020-10-01
    35712, # My Girlfriend is too much to handle | Russia + French 2017-10-01 - 2020-10-01
    36094, # Hakumei and Mikochi (Hakumei to Mikochi) | Russia + French 2018-01-01 - 2022-01-01
    1546, # Negima?! | Russia + French 2018-01-01 - 2022-01-01
    157, # Negima! (Mahou Sensei Negima!) | Russia + French 2018-01-01 - 2022-01-01
    34279, # Record of Grancrest War (Grancrest Senki) | Russia + East Europe - 2018-01-01 - 2025-12-31
    35997, # Marchen Madchen | Russia + Europe - 2018-01-11 - 2020-01-11
    36511, # Tokyo Ghoul:re | Russia + East Europe - 2018-04-01 - 2023-04-01
    30484, # Steins;Gate 0 | Russia + Germany - 2018-04-01 - 2025-04-01
    16498, # Attack on Titan 1 | Russia - 2018-07-22 - 2022-07-21
    25777, # Attack on Titan 2 | Russia - 2018-07-22 - 2022-07-21
    35760, # Attack on Titan 3 | Russia - 2018-07-22 - 2022-07-21
    37597, # Dakaretai Otoko 1-i ni Odosarete Imasu | Russia + Europe - 2018-10-01 - 2023-10-01
    37450, # Seishun Buta Yarou wa Bunny Girl Senpai no Yume wo Minai | Russia + Erope - 2018-10-01 - 2023-10-01
    36474, # Sword Art Online: Alicization | Russia + Erope - 2018-10-01 - 2025-10-01
    35540, # Slow Start | Russia + Europe - 2018-01-01 - 2025-01-01
    37349, # Goblin Slayer | Russia - 2018-10-01 - 2022-09-30
    31646, # March comes in like a lion | Russia + Europe - 2017-07-01 - 2024-07-01
    # 37675, # Overlord III
    # 37140, # GeGeGe no Kitaro
    # 36726, # Yuuna and the Haunted Hot Springs
    # 36023, # PERSONA5 the Animation
    # 36475, # SWORD ART ONLINE ALTERNATIVE «GUN GALE ONLINE»
    # 25537, # Fate/stay night: Heaven's Feel I. presage flower
    # 37141, # Cells at Work (TV)
    # 35840 # Cells at Work
    37979, # Magical Girl Spec-Ops Asuka | Russia + French - 2018-04-01 - 2022-04-01
    37451, # Boogiepop wa Warawanai (2019) | Russia + French - 2018-04-01 - 2022-04-01
    36633, # Date A Live III | Russia + French - 2018-04-01 - 2022-04-01
    37140, # Gegege no Kitarou | Russia and Russian speaking territories + French and French speaking territories - 2018-04-19 - 2021-10-18
    # 21 episodes 861 - 910 # One Piece | Russia and Russian speaking territories + Germany and German speaking territories - 2018-10-11 - 2020-05-10
    37999, # Kaguya-sama wa Kokurasetai | Russia and Russian speaking territories + French and French speaking territories - 2019-01-01 - 2023-01-01
    37779, # The Promised Neverland | Russia and Russian speaking territories + French and French speaking territories - 2019-01-01 - 2026-01-01
  ]
end
