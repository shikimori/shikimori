class User
  module Roles
    GuestID = 5
    Morr_ID = 1
    Banhammer_ID = 6942
    Blackchestnut_ID = 1077
    Cosplayer_ID = 1680

    # access rights
    Admins = [Morr_ID, Blackchestnut_ID]
    Moderators = (Admins + [921, 11, 188, 93, 861]).uniq # 2 - Adelor, 93 - lena-chan, 861 - Oniii-chan
    ReviewsModerators = (Admins + []).uniq # + Moderators
    UserChangesModerators = (Admins + [11, 921, 188, 94, 942, 392, 16148, 21887]).uniq # 921 - sfairat, 188 - Forever Autumn, 11 - BlackMetalFan, 94 - AcidEmily, 942 - Иштаран, 392 - Tehanu, 16148 - Alex Minson, 21887 - Joseph
    AbuseRequestsModerators = (Admins + Moderators + [11, 188, 950]).uniq # Daiver
    NewsMakers = (Admins + []).uniq
    Translators = (Admins + UserChangesModerators + [28, 19, 31, 41, 942]).uniq
    ContestsModerators = (Admins + [1483]).uniq # 1483 - Zula
    CosplayModerators = (Admins + [2043, 2046]).uniq # 2043 - laitqwerty, 2046 - Котейка
    # 11496 - АлхимиК, 4099 - sttany, 12771 - spinosa, 13893 - const, 11883 - Tenno Haruka, 5064 - Heretic, 5779 - Lumennes,
    # 14633 - Dracule404, 5255 - GArtem, 7028 - Drako Black, 15905 - Youkai_Ririko, 3954 - Xellos("ゼロス"), 23616 - Vi Vi,
    # 25082 - SkywalterDBZ
    VideoModerators = (Admins + [11496, 4099, 12771, 13893, 11883, 5064, 5779, 14633, 5255, 7028, 15905, 3954, 23616, 25082]).uniq
    # 16750 - hichigo shirosaki, 16774 - torch8870, 10026 - Johnny_W, 20455 - Doflein, 10026 - Black_Heart, 12023 - Wooterland,
    # 8237 - AmahiRazu, 17423 - Ryhiy, 11834 - .ptax.log, 21347 - アナスタシア, 4792 - artemeliy, 19638 - milaha007, 10342 - gazig
    # 20483 - Крипке, 16858 - ✿Yuki Yu✿, 34724 - Edge, 28601 - Ankalimon
    TrustedVideoUploaders = (Admins + VideoModerators + [16750, 16774, 10026, 20455, 10026, 12023, 8237, 17423, 11834, 21347, 4792, 10342, 20483, 16858, 34724, 28601]).uniq

    # администратор ли пользователь?
    def admin?
      Admins.include? self.id
    end

    # банхаммер ли пользователь
    def banhammer?
      self.id == Banhammer_ID
    end

    # модератор ли пользователь,
    def moderator?
      Moderators.include? self.id
    end

    # модератор ли пользовательских правок пользователь?
    def user_changes_moderator?
      UserChangesModerators.include? self.id
    end

    # модератор ли пользовательских правок пользователь?
    def abuse_requests_moderator?
      AbuseRequestsModerators.include? self.id
    end

    # модератор ли обзоров пользователь?
    def reviews_moderator?
      ReviewsModerators.include? self.id
    end

    # модератор ли контестов пользователь?
    def contests_moderator?
      ContestsModerators.include? self.id
    end

    # модератор ли косплея пользователь?
    def cosplay_moderator?
      CosplayModerators.include? self.id
    end

    # модератор ли видео пользователь?
    def video_moderator?
      VideoModerators.include? self.id
    end

    # ответственный ли за новости пользователь?
    def newsmaker?
      NewsMakers.include? self.id
    end

    # переводчик ли пользователь
    def translator?
      Translators.include? self.id
    end

    # пользователь, за которым не проверяем залитое виде?
    def trusted_video_uploader?
      TrustedVideoUploaders.include? self.id
    end
  end
end
