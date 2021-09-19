class FillUserRoles < ActiveRecord::Migration[5.1]
  ADMIN_IDS = [1]
  FORUM_MODERATOR_IDS = (ADMIN_IDS + [921, 93, 861, 16_148]).uniq
  REVIEW_MODERATOR_IDS = (ADMIN_IDS + [16_148]).uniq
  COLLECTION_MODERATOR_IDS = (ADMIN_IDS + [16_148]).uniq
  VERSION_MODERATOR_IDS = (ADMIN_IDS + [921, 392, 16_148, 21_887]).uniq
  TRANSLATOR_IDS = (ADMIN_IDS + VERSION_MODERATOR_IDS + [28, 19, 31, 41]).uniq
  CONTEST_MODERATOR_IDS = (ADMIN_IDS + [4261]).uniq
  COSPLAY_MODERATOR_IDS = (ADMIN_IDS + [2043, 20_46]).uniq
    11_496, 4_099, 13_893, 11_883, 5_064, 5_779, 146_33, 5_255,
    7_028, 15_905, 3_954, 23_616, 25_082, 30_214
  ]).uniq

  ROLES = {
    admin: ADMIN_IDS,
    forum_moderator: FORUM_MODERATOR_IDS,
    critique_moderator: REVIEW_MODERATOR_IDS,
    collection_moderator: COLLECTION_MODERATOR_IDS,
    version_moderator: VERSION_MODERATOR_IDS,
    translator: TRANSLATOR_IDS,
    contest_moderator: CONTEST_MODERATOR_IDS,
    cosplay_moderator: COSPLAY_MODERATOR_IDS,
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
