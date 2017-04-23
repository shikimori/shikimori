class TranslateContests < ActiveRecord::Migration[5.0]
  def change
    translate_contests
  end

  private

  def translate_contests
    Contest.where(id: 1).update_all(title_en: 'The Best Anime of Summer 2012')
    Contest.where(id: 2).update_all(title_en: 'The Best Anime of Spring 2012')
    Contest.where(id: 3).update_all(title_en: 'The Best Anime of Winter 2012')
    Contest.where(id: 4).update_all(title_en: 'The Best Anime of Fall 2012')
    Contest.where(id: 5).update_all(title_en: 'The Best OVA of 2012')
    Contest.where(id: 6).update_all(title_en: 'The Best Romance Anime')
    Contest.where(id: 7).update_all(title_en: 'The Most Promising Anime of Summer 2013')
    Contest.where(id: 8).update_all(title_en: 'The Best Anime of 2012')
    Contest.where(id: 9).update_all(title_en: 'The Best Anime of Winter 2013')
    Contest.where(id: 10).update_all(title_en: 'The Best Anime of Studio Toei Animation')
    Contest.where(id: 11).update_all(title_en: 'The Best Anime of Studio Sunrise')
    Contest.where(id: 12).update_all(title_en: 'The Best Anime of Studio Madhouse Studios')
    Contest.where(id: 13).update_all(title_en: 'The Best Anime of Studio J.C. Staff Studio')
    Contest.where(id: 14).update_all(title_en: 'The Best Anime of 2011')
    Contest.where(id: 16).update_all(title_en: 'The Best Anime of Studio Production I.G.')
    Contest.where(id: 17).update_all(title_en: 'The Best Anime of Spring 2013')
    Contest.where(id: 18).update_all(title_en: 'The Best Comedy Anime')
    Contest.where(id: 19).update_all(title_en: 'The Best Anime of Studio Pierrot!')
    Contest.where(id: 20).update_all(title_en: 'The Most Promising Anime of Fall 2013')
    Contest.where(id: 21).update_all(title_en: 'The Best Ecchi Anime')
    Contest.where(id: 22).update_all(title_en: 'The Best Femail Character')
    Contest.where(id: 23).update_all(title_en: 'The Best Male Character')
    Contest.where(id: 24).update_all(title_en: 'The Best Anime of Summer 2013')
    Contest.where(id: 25).update_all(title_en: 'The Best Anime of Studio Studio DEEN')
    Contest.where(id: 29).update_all(title_en: 'The Least Favorite Female Character')
    Contest.where(id: 30).update_all(title_en: 'The Least Favorite Male Character')
    Contest.where(id: 31).update_all(title_en: 'The Most Promising Anime of Winter 2014')
    Contest.where(id: 32).update_all(title_en: 'The Best Antagonist')
    Contest.where(id: 33).update_all(title_en: 'The Most Promising Anime of Spring 2014')
    Contest.where(id: 34).update_all(title_en: 'The Best Lier')
    Contest.where(id: 35).update_all(title_en: 'The Best Anime of Fall 2013')
  end
end

#1: Лучшие аниме лета 2012 года
#2: Лучшие аниме весны 2012 года
#3: Лучшие аниме зимы 2012 года
#4: Лучшие аниме осени 2012 года
#5: Лучшая OVA 2012 года
#6: Лучшие романтические сериалы
#7: Самое многообещающее аниме летнего сезона 2013!
#8: Лучшие аниме 2012 года
#9: Лучшие аниме зимы 2013 года
#10: Лучшие аниме студии Toei Animation
#11: Лучшие аниме студии Sunrise
#12: Лучшие аниме студии Madhouse Studios
#13: Лучшие аниме студии J.C. Staff
#14: Лучшие аниме 2011 года!
#16: Лучшие аниме студии Production I.G
#17: Лучшие аниме весны 2013 года
#18: Лучшие комедийные аниме
#19: Лучшее аниме студии Studio Pierrot!
#20: Самое многообещающее аниме осеннего сезона 2013!
#21: Лучший этти сериал
#22: Лучший женский персонаж
#23: Лучший мужской персонаж
#24: Лучшее аниме лета 2013!
#25: Лучшее аниме студии Studio DEEN!
#26: Лучший экшен!
#29: Самый нелюбимый женский персонаж
#30: Самый нелюбимый мужской персонаж
#31: Самое многообещающее аниме зимнего сезона 2014!
#32: Лучший антагонист!
#33: Самое многообещающее аниме весеннего сезона 2014!
#34: Лучший лжец!
#35: Лучшее аниме осеннего сезона 2013!
#40: Самая каноничная цундере!
#39: Самое многообещающее аниме летнего сезона 2014!
#36: Лучшая улыбка маньяка / Rape face!
#37: Лучшее аниме студии AIC!
#44: Самое многообещающее аниме осеннего сезона 2014!
#45: Лучшее аниме весеннего сезона 2014!
#38: Лучшее аниме зимнего сезона 2014!
#47: Самое многообещающее аниме зимнего сезона 2015!
#43: Лучший персонаж в аниме студии Shaft
#42: Лучшее сверхъестественное аниме
#41: Лучшее аниме студии XEBEC!
#54: Самое многообещающее аниме летнего сезона 2015!
#48: Лучшее аниме 2013 года
#51: Самое многообещающее аниме весеннего сезона 2015!
#53: Лучший GAR-персонаж
#46: Лучшее аниме студии TMS Entertainment(Tokyo Movie Shinsha)!
#56: Лучшее аниме студии A-1 Pictures Inc.
#55: Лучшее аниме зимнего сезона 2015!
#50: Лучшее аниме студии Tatsunoko Productions!
#49: Лучшее аниме летнего сезона 2014
#52: Лучшее аниме осеннего сезона 2014
#59: Лучшее аниме 2014 года!
#28: Самый крутой жрец/священник
#57: Опрос на лучшую суперспособность!
#58: Лучший персонаж с архетипом кудере!
#60: Лучшее аниме весеннего сезона 2015
#61: Лучшее аниме летнего сезона 2015!
#62: Лучшее аниме жанра спокон (спорт)
#63: Лучшее аниме осеннего сезона 2015
#65: Лучшее аниме студии Gonzo
#64: Лучшая младшая сестрёнка
#67: Лучший персонаж в очках
#66: Лучшее аниме зимнего сезона 2016
#68: Лучшее аниме весеннего сезона 2016
#70: Лучшее аниме студии Bones
#71: Лучшее аниме 2015 года
#69: Лучшее аниме летнего сезона 2016
#73: Лучшее аниме студии Brains Base
#72: Лучший убийца
#74: Самое переоцененное аниме
#75: Лучшая девушка-боец
#77: Лучший ученый
#76: Лучшее аниме осеннего сезона 2016
