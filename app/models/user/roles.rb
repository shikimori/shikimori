class User
  module Roles
    GUEST_ID = 5
    MORR_ID = 1
    BANHAMMER_ID = 6942
    COSPLAYER_ID = 1680

    # access rights
    ADMINS = [MORR_ID, 13]
    MODERATORS = (ADMINS + [921, 11, 188, 93, 861, 16148]).uniq # 2 - Adelor, 93 - lena-chan, 861 - Oniii-chan
    REVIEWS_MODERATORS = (ADMINS + [16148]).uniq # 16148 - Alex Minson,
    VERSIONS_MODERATORS = (ADMINS + [11, 921, 188, 94, 392, 16148, 21887]).uniq # 921 - sfairat, 188 - Forever Autumn, 11 - BlackMetalFan, 94 - AcidEmily, 392 - Tehanu, 16148 - Alex Minson, 21887 - Joseph
    TRANSLATORS = (ADMINS + VERSIONS_MODERATORS + [28, 19, 31, 41]).uniq
    CONTEST_MODERATORS = (ADMINS + [1483]).uniq # 1483 - Zula
    COSPLAY_MODERATORS = (ADMINS + [2043, 2046]).uniq # 2043 - laitqwerty, 2046 - Котейка
    # 11496 - АлхимиК, 4099 - sttany, 12771 - spinosa, 13893 - const, 11883 - Tenno Haruka, 5064 - Heretic, 5779 - Lumennes,
    # 14633 - Dracule404, 5255 - GArtem, 7028 - Drako Black, 15905 - Youkai_Ririko, 3954 - Xellos("ゼロス"), 23616 - Vi Vi,
    # 25082 - SkywalterDBZ
    VIDEO_MODERATORS = (ADMINS + [11496, 4099, 12771, 13893, 11883, 5064, 5779, 14633, 5255, 7028, 15905, 3954, 23616, 25082]).uniq
    TRUSTED_VIDEO_UPLOADERS = (ADMINS + VIDEO_MODERATORS + [
      16750, 16774, 10026, 20455, 10026, 12023, 8237, 17423, 11834, 21347,
      4792, 10342, 20483, 16858, 34724, 28601, 24518, 5019, 40713, 16178,
      17532, 33635, 44418, 15511, 17916, 30214, 16178, 47440, 11942, 52936,
      38439, 38439, 48509, 53634
    ]).uniq

    # администратор ли пользователь?
    def admin?
      ADMINS.include? self.id
    end

    # банхаммер ли пользователь
    def banhammer?
      self.id == BANHAMMER_ID
    end

    # модератор ли пользователь,
    def moderator?
      MODERATORS.include? self.id
    end

    # модератор ли пользовательских правок пользователь?
    def versions_moderator?
      VERSIONS_MODERATORS.include? self.id
    end

    # модератор ли обзоров пользователь?
    def reviews_moderator?
      REVIEWS_MODERATORS.include? self.id
    end

    # модератор ли контестов пользователь?
    def contests_moderator?
      CONTEST_MODERATORS.include? self.id
    end

    # модератор ли косплея пользователь?
    def cosplay_moderator?
      COSPLAY_MODERATORS.include? self.id
    end

    # модератор ли видео пользователь?
    def video_moderator?
      VIDEO_MODERATORS.include? self.id
    end

    # переводчик ли пользователь
    def translator?
      TRANSLATORS.include? self.id
    end

    # пользователь, за которым не проверяем залитое видео?
    def trusted_video_uploader?
      TRUSTED_VIDEO_UPLOADERS.include? self.id
    end
  end
end
