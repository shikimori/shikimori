class TranslateContests < ActiveRecord::Migration[5.0]
  def up
    translate_contests
  end

  def down
    Contest.update_all(title_en: nil)
  end

  private

  def translate_contests
    Contest.where(id: 1).update_all(title_en: 'The Best Anime of Summer 2012')
    Contest.where(id: 2).update_all(title_en: 'The Best Anime of Spring 2012')
    Contest.where(id: 3).update_all(title_en: 'The Best Anime of Winter 2012')
    Contest.where(id: 4).update_all(title_en: 'The Best Anime of Fall 2012')
    Contest.where(id: 5).update_all(title_en: 'The Best OVA of 2012')
    Contest.where(id: 6).update_all(title_en: 'The Best Romance Anime')
    Contest.where(id: 7).update_all(title_en: 'The Most Promising Anime of Summer 2013!')
    Contest.where(id: 8).update_all(title_en: 'The Best Anime of 2012')
    Contest.where(id: 9).update_all(title_en: 'The Best Anime of Winter 2013')
    Contest.where(id: 10).update_all(title_en: 'The Best Anime of Studio Toei Animation')
    Contest.where(id: 11).update_all(title_en: 'The Best Anime of Studio Sunrise')
    Contest.where(id: 12).update_all(title_en: 'The Best Anime of Studio Madhouse Studios')
    Contest.where(id: 13).update_all(title_en: 'The Best Anime of Studio J.C. Staff Studio')
    Contest.where(id: 14).update_all(title_en: 'The Best Anime of 2011!')
    Contest.where(id: 16).update_all(title_en: 'The Best Anime of Studio Production I.G')
    Contest.where(id: 17).update_all(title_en: 'The Best Anime of Spring 2013')
    Contest.where(id: 18).update_all(title_en: 'The Best Comedy Anime')
    Contest.where(id: 19).update_all(title_en: 'The Best Anime of Studio Pierrot!')
    Contest.where(id: 20).update_all(title_en: 'The Most Promising Anime of Fall 2013!')
    Contest.where(id: 21).update_all(title_en: 'The Best Ecchi Anime')
    Contest.where(id: 22).update_all(title_en: 'The Best Female Character')
    Contest.where(id: 23).update_all(title_en: 'The Best Male Character')
    Contest.where(id: 24).update_all(title_en: 'The Best Anime of Summer 2013!')
    Contest.where(id: 25).update_all(title_en: 'The Best Anime of Studio Studio DEEN!')
    Contest.where(id: 26).update_all(title_en: 'The Best Action Anime!')
    Contest.where(id: 28).update_all(title_en: 'The Coolest Priest')
    Contest.where(id: 29).update_all(title_en: 'The Least Favorite Female Character')
    Contest.where(id: 30).update_all(title_en: 'The Least Favorite Male Character')
    Contest.where(id: 31).update_all(title_en: 'The Most Promising Anime of Winter 2014!')
    Contest.where(id: 32).update_all(title_en: 'The Best Antagonist!')
    Contest.where(id: 33).update_all(title_en: 'The Most Promising Anime of Spring 2014!')
    Contest.where(id: 34).update_all(title_en: 'The Best Lier!')
    Contest.where(id: 35).update_all(title_en: 'The Best Anime of Fall 2013!')
    Contest.where(id: 36).update_all(title_en: 'The Best Rape Face!')
    Contest.where(id: 37).update_all(title_en: 'The Best Anime of Studio AIC!')
    Contest.where(id: 38).update_all(title_en: 'The Best Anime of Winter 2014!')
    Contest.where(id: 39).update_all(title_en: 'The Most Promising Anime of Summer 2014!')
    Contest.where(id: 40).update_all(title_en: 'The Most Typical Tsundere!')
    Contest.where(id: 41).update_all(title_en: 'The Best Anime of Studio XEBEC!')
    Contest.where(id: 42).update_all(title_en: 'The Best Supernatural Anime')
    Contest.where(id: 43).update_all(title_en: 'The Best Character of Studio Shaft')
    Contest.where(id: 44).update_all(title_en: 'The Most Promising Anime of Fall 2014!')
    Contest.where(id: 45).update_all(title_en: 'The Best Anime of Spring 2014!')
    Contest.where(id: 46).update_all(title_en: 'The Best Anime of Studio TMS Entertainment (Tokyo Movie Shinsha)!')
    Contest.where(id: 47).update_all(title_en: 'The Most Promising Anime of Winter 2015!')
    Contest.where(id: 48).update_all(title_en: 'The Best Anime of 2013')
    Contest.where(id: 49).update_all(title_en: 'The Best Anime of Summer 2014')
    Contest.where(id: 50).update_all(title_en: 'The Best Anime of Studio Tatsunoko Productions!')
    Contest.where(id: 51).update_all(title_en: 'The Most Promising Anime of Spring 2015!')
    Contest.where(id: 52).update_all(title_en: 'The Best Anime of Fall 2014')
    Contest.where(id: 53).update_all(title_en: 'The Best GAR Character')
    Contest.where(id: 54).update_all(title_en: 'The Most Promising Anime of Summer 2015!')
    Contest.where(id: 55).update_all(title_en: 'The Best Anime of Winter 2015!')
    Contest.where(id: 56).update_all(title_en: 'The Best Anime of Studio A-1 Pictures Inc.')
    Contest.where(id: 57).update_all(title_en: 'The Best Superpower!')
    Contest.where(id: 58).update_all(title_en: 'The Best Kuudere Character!')
    Contest.where(id: 59).update_all(title_en: 'The Best Anime of 2014!')
    Contest.where(id: 60).update_all(title_en: 'The Best Anime of Spring 2015')
    Contest.where(id: 61).update_all(title_en: 'The Best Anime of Summer 2015!')
    Contest.where(id: 62).update_all(title_en: 'The Best Sports Anime')
    Contest.where(id: 63).update_all(title_en: 'The Best Anime of Fall 2015')
    Contest.where(id: 64).update_all(title_en: 'The Best Imouto')
    Contest.where(id: 65).update_all(title_en: 'The Best Anime of Studio Gonzo')
    Contest.where(id: 66).update_all(title_en: 'The Best Anime of Winter 2016')
    Contest.where(id: 67).update_all(title_en: 'The Best Character With Glasses')
    Contest.where(id: 68).update_all(title_en: 'The Best Anime of Spring 2016')
    Contest.where(id: 69).update_all(title_en: 'The Best Anime of Summer 2016')
    Contest.where(id: 70).update_all(title_en: 'The Best Anime of Studio Bones')
    Contest.where(id: 71).update_all(title_en: 'The Best Anime of 2015')
    Contest.where(id: 72).update_all(title_en: 'The Best Assassin')
    Contest.where(id: 73).update_all(title_en: 'The Best Anime of Studio Brains Base')
    Contest.where(id: 74).update_all(title_en: 'The Most Overrated Anime')
    Contest.where(id: 75).update_all(title_en: 'The Best Warrior Girl')
    Contest.where(id: 76).update_all(title_en: 'The Best Anime of Fall 2016')
    Contest.where(id: 77).update_all(title_en: 'The Best Scientist')
  end
end

#1: Лучшие аниме лета 2012 года
#10: Лучшие аниме студии Toei Animation
#11: Лучшие аниме студии Sunrise
#12: Лучшие аниме студии Madhouse Studios
#13: Лучшие аниме студии J.C. Staff
#14: Лучшие аниме 2011 года!
#16: Лучшие аниме студии Production I.G
#17: Лучшие аниме весны 2013 года
#18: Лучшие комедийные аниме
#19: Лучшее аниме студии Studio Pierrot!
#2: Лучшие аниме весны 2012 года
#20: Самое многообещающее аниме осеннего сезона 2013!
#21: Лучший этти сериал
#22: Лучший женский персонаж
#23: Лучший мужской персонаж
#24: Лучшее аниме лета 2013!
#25: Лучшее аниме студии Studio DEEN!
#26: Лучший экшен!
#28: Самый крутой жрец/священник
#29: Самый нелюбимый женский персонаж
#3: Лучшие аниме зимы 2012 года
#30: Самый нелюбимый мужской персонаж
#31: Самое многообещающее аниме зимнего сезона 2014!
#32: Лучший антагонист!
#33: Самое многообещающее аниме весеннего сезона 2014!
#34: Лучший лжец!
#35: Лучшее аниме осеннего сезона 2013!
#36: Лучшая улыбка маньяка / Rape face!
#37: Лучшее аниме студии AIC!
#38: Лучшее аниме зимнего сезона 2014!
#39: Самое многообещающее аниме летнего сезона 2014!
#40: Самая каноничная цундере!
#41: Лучшее аниме студии XEBEC!
#42: Лучшее сверхъестественное аниме
#43: Лучший персонаж в аниме студии Shaft
#44: Самое многообещающее аниме осеннего сезона 2014!
#45: Лучшее аниме весеннего сезона 2014!
#46: Лучшее аниме студии TMS Entertainment(Tokyo Movie Shinsha)!
#47: Самое многообещающее аниме зимнего сезона 2015!
#48: Лучшее аниме 2013 года
#49: Лучшее аниме летнего сезона 2014
#4: Лучшие аниме осени 2012 года
#50: Лучшее аниме студии Tatsunoko Productions!
#51: Самое многообещающее аниме весеннего сезона 2015!
#52: Лучшее аниме осеннего сезона 2014
#53: Лучший GAR-персонаж
#54: Самое многообещающее аниме летнего сезона 2015!
#55: Лучшее аниме зимнего сезона 2015!
#56: Лучшее аниме студии A-1 Pictures Inc.
#57: Опрос на лучшую суперспособность!
#58: Лучший персонаж с архетипом кудере!
#59: Лучшее аниме 2014 года!
#5: Лучшая OVA 2012 года
#60: Лучшее аниме весеннего сезона 2015
#61: Лучшее аниме летнего сезона 2015!
#62: Лучшее аниме жанра спокон (спорт)
#63: Лучшее аниме осеннего сезона 2015
#64: Лучшая младшая сестрёнка
#65: Лучшее аниме студии Gonzo
#66: Лучшее аниме зимнего сезона 2016
#67: Лучший персонаж в очках
#68: Лучшее аниме весеннего сезона 2016
#69: Лучшее аниме летнего сезона 2016
#6: Лучшие романтические сериалы
#70: Лучшее аниме студии Bones
#71: Лучшее аниме 2015 года
#72: Лучший убийца
#73: Лучшее аниме студии Brains Base
#74: Самое переоцененное аниме
#75: Лучшая девушка-боец
#76: Лучшее аниме осеннего сезона 2016
#77: Лучший ученый
#7: Самое многообещающее аниме летнего сезона 2013!
#8: Лучшие аниме 2012 года
#9: Лучшие аниме зимы 2013 года
