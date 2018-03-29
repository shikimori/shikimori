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

  OTHER_COPYRIGHTED = [
    # письмо от post@webkontrol.ru на mail+copyright@shikimori.org
    # [Notice_ID:*IdOAQy*] Nintendo Company Ltd - Нарушение прав правообладателей / Nintendo Company Ltd - Abuse
    19157,
    # istari
    32281, # Kimi no Na wa
    # vgtrk
    34541, # Mary to Majo no Hana
    # Capella Film
    33970, # Girls und Panzer das Finale
    35851 # Sayonara no Asa ni Yakusoku no Hana wo Kazarou
  ]

  WAKANIM_COPYRIGHTED = [
    36144, # Garo: Vanishing Line - Wakanim (Russia + Eastern Europe) 2017-10-01 - 2024-10-01
    35078, # Mitsuboshi Colors - Wakanim (Russia + Europe except Italy&Spanish) 2018-08-01 - 2022-07-01
    33354, # Cardcaptor Sakura: Clear Card-hen - Wakanim (Russia + French) 2018-01-01 - 2022-01-01
    35320, # Cardcaptor Sakura: Clear Card-hen Prologue - Sakura and two Bears - Wakanim (Russia + French) 2018-01-01 - 2022-01-01
    35073, # Overlord II - Wakanim (Russia) 2018-01-01 - 2022-01-01
    33478, # UQ Holder!: Mahou Sensei Negima! 2 - Wakanim (Russia) 2017-10-01 - 2024-10-01
    36027, # King's Game - Wakanim (Russia + French) 2017-10-01 - 2024-10-01
    35838, # Girls' Last Tour - Wakanim (Russia + French) 2017-10-01 - 2020-10-01
    35712, # My Girlfriend is too much to handle - Wakanim (Russia + French) 2017-10-01 - 2020-10-01
    36094, # Hakumei to Mikochi - Wakanim (Russia + French) 2018-01-01 - 2022-01-01
    1546, # Negima?! - Wakanim (Russia + French) 2018-01-01 - 2022-01-01
    157, # Mahou Sensei Negima! - Wakanim (Russia + French) 2018-01-01 - 2022-01-01
  ]

  # http://antipiracy.ivi.ru/Starz_Media_prizrak_gorod_mechty.pdf
  IVI_RU_COPYRIGHTED = [
    801 # Ghost in the Shell: Stand Alone Complex 2nd GIG
  ]
  IVI_RU_PLAYERS = {
    801 => '//www.ivi.ru/external/seriesembed/?compilationId=7561'
  }
end
