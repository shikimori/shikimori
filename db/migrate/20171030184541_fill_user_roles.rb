class FillUserRoles < ActiveRecord::Migration[5.1]
  ADMIN_IDS = [1]
  FORUM_MODERATOR_IDS = (ADMIN_IDS + [921, 93, 861, 16_148]).uniq
  REVIEW_MODERATOR_IDS = (ADMIN_IDS + [16_148]).uniq
  COLLECTION_MODERATOR_IDS = (ADMIN_IDS + [16_148]).uniq
  VERSION_MODERATOR_IDS = (ADMIN_IDS + [921, 392, 16_148, 21_887]).uniq
  TRANSLATOR_IDS = (ADMIN_IDS + VERSION_MODERATOR_IDS + [28, 19, 31, 41]).uniq
  CONTEST_MODERATOR_IDS = (ADMIN_IDS + [4261]).uniq
  COSPLAY_MODERATOR_IDS = (ADMIN_IDS + [2043, 20_46]).uniq
  VIDEO_MODERATOR_IDS = (ADMIN_IDS + [
    11_496, 4_099, 13_893, 11_883, 5_064, 5_779, 146_33, 5_255,
    7_028, 15_905, 3_954, 23_616, 25_082, 30_214
  ]).uniq
  VIDEO_SUPER_MODERATOR_IDS = [30_214]
  API_VIDEO_UPLOADER_IDS = [4_193, 47_142]
  TRUSTED_VIDEO_UPLOADER_IDS = (ADMIN_IDS + VIDEO_MODERATOR_IDS + API_VIDEO_UPLOADER_IDS + [
    16_750, 16_774, 10_026, 20_455, 10_026, 12_023, 8_237, 17_423, 11_834,
    21_347, 4_792, 10_342, 20_483, 16_858, 34_724, 28_601, 24_518, 5_019,
    40_713, 16_178, 17_532, 33_635, 44_418, 15_511, 17_916, 30_214, 16_178,
    47_440, 11942, 52936, 38_439, 38_439, 48_509, 53_634, 41_912, 91_485,
    13_7461, 101_610
  ]).uniq

  ROLES = {
    admin: ADMIN_IDS,
    forum_moderator: FORUM_MODERATOR_IDS,
    review_moderator: REVIEW_MODERATOR_IDS,
    collection_moderator: COLLECTION_MODERATOR_IDS,
    version_moderator: VERSION_MODERATOR_IDS,
    translator: TRANSLATOR_IDS,
    contest_moderator: CONTEST_MODERATOR_IDS,
    cosplay_moderator: COSPLAY_MODERATOR_IDS,
    video_moderator: VIDEO_MODERATOR_IDS,
    video_super_moderator: VIDEO_SUPER_MODERATOR_IDS,
    api_video_uploader: API_VIDEO_UPLOADER_IDS,
    trusted_video_uploader: TRUSTED_VIDEO_UPLOADER_IDS,
    not_trusted_video_uploader: [56_231, 51_467, 39_594],
    trusted_video_changer: [101_610],
    trusted_version_changer: [188, 94, 159666],
    trusted_ranobe_external_links_changer: [17802, 6675],
    not_trusted_version_changer: [65_255, 47_807],
    bot: [13, 14, 15, 16, 1680, 6942],
    censored_avatar: [4357, 24433, 48544],
    censored_profile: [28046]
  }

  def up
    ROLES.each do |role, ids|
      User.where(id: ids).each do |user|
        unless user.send "#{role}?"
          user.roles << role
          user.save!
        end
      end
    end
  end
end
