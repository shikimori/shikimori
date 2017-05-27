class User
  module Roles
    GUEST_ID = 5
    MORR_ID = 1
    BANHAMMER_ID = 6_942
    COSPLAYER_ID = 1_680

    BAKSIII_ID = 30_214

    # access rights
    ADMINS = [MORR_ID]
    MODERATORS = (ADMINS + [921, 93, 861, 16_148]).uniq # 93 - lena-chan, 861 - Oniii-chan
    REVIEWS_MODERATORS = (ADMINS + [16_148]).uniq # 16148 - Alex Minson,
    VERSIONS_MODERATORS = (ADMINS + [921, 392, 16_148, 21_887]).uniq # 921 - sfairat, 11 - BlackMetalFan, 94 - AcidEmily, 392 - Tehanu, 16148 - Alex Minson, 21887 - Joseph
    TRANSLATORS = (ADMINS + VERSIONS_MODERATORS + [28, 19, 31, 41]).uniq
    CONTEST_MODERATORS = (ADMINS + [4261]).uniq # 4261 - Zepheles
    COSPLAY_MODERATORS = (ADMINS + [2043, 20_46]).uniq # 2043 - laitqwerty, 2046 - Котейка
    # 11496 - АлхимиК, 4099 - sttany, 12771 - spinosa, 13893 - const, 11883 - Tenno Haruka, 5064 - Heretic, 5779 - Lumennes,
    # 14633 - Dracule404, 5255 - GArtem, 7028 - Drako Black, 15905 - Youkai_Ririko, 3954 - Xellos("ゼロス"), 23616 - Vi Vi,
    # 25082 - SkywalterDBZ, 30214 - baksIII
    VIDEO_MODERATORS = (ADMINS + [
      11_496, 4_099, 12_771, 13_893, 11_883, 5_064, 5_779, 146_33, 5_255,
      7_028, 15_905, 3_954, 23_616, 25_082, 30_214
    ]).uniq
    API_VIDEO_UPLOADERS = [4_193,  47_142]
    TRUSTED_VIDEO_UPLOADERS = (ADMINS + VIDEO_MODERATORS + API_VIDEO_UPLOADERS + [
      16_750, 16_774, 10_026, 20_455, 10_026, 12_023, 8_237, 17_423, 11_834,
      21_347, 4_792, 10_342, 20_483, 16_858, 34_724, 28_601, 24_518, 5_019,
      40_713, 16_178, 17_532, 33_635, 44_418, 15_511, 17_916, 30_214, 16_178,
      47_440, 11942, 52936, 38_439, 38_439, 48_509, 53_634, 41_912, 91_485,
      13_7461
    ]).uniq
    NOT_TRUSTED_VIDEO_UPLOADERS = [56_231]
    TRUSTED_VIDEO_CHANGERS = [101_610] # 10610 - s.t.a.l.k.e.r
    TRUSTED_VERSION_CHANGERS = [188, 94, 159666] # 188 - Autumn, 94 - acid_emily, 159666 - Nanochka
    TRUSTED_RANOBE_EXTERNAL_LINKS_CHANGERS = [17802, 6675] # 17802 - samogot, 6675 - Gurebu

    VERSION_VERMINS = [
      65_255
    ]

    def admin?
      ADMINS.include? id
    end

    def banhammer?
      id == BANHAMMER_ID
    end

    # модератор ли пользователь,
    def moderator?
      MODERATORS.include? id
    end

    def versions_moderator?
      VERSIONS_MODERATORS.include? id
    end

    def reviews_moderator?
      REVIEWS_MODERATORS.include? id
    end

    # модератор ли контестов пользователь?
    def contests_moderator?
      CONTEST_MODERATORS.include? id
    end

    def cosplay_moderator?
      COSPLAY_MODERATORS.include? id
    end

    def video_moderator?
      VIDEO_MODERATORS.include? id
    end

    def translator?
      TRANSLATORS.include? id
    end

    def trusted_video_uploader?
      TRUSTED_VIDEO_UPLOADERS.include? id
    end

    def trusted_version_changer?
      TRUSTED_VERSION_CHANGERS.include? id
    end

    def trusted_ranobe_external_links_changer?
      TRUSTED_RANOBE_EXTERNAL_LINKS_CHANGERS.include? id
    end

    def trusted_video_changer?
      TRUSTED_VIDEO_CHANGERS.include? id
    end

    def api_video_uploader?
      API_VIDEO_UPLOADERS.include? id
    end

    def verison_vermin?
      VERSION_VERMINS.include? id
    end
  end
end
