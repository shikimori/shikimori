describe Versions::RoleVersion do
  describe '#action' do
    let(:version) { build :role_version, item_diff: { action: 'add' } }
    it { expect(version.action).to eq Versions::RoleVersion::Actions[:add] }
  end

  describe '#role' do
    let(:version) { build :role_version, item_diff: { role: 'super_moderator' } }
    it { expect(version.role).to eq Types::User::Roles[:super_moderator] }
  end

  describe '#apply_changes' do
    let(:version) do
      build :role_version,
        item: user_admin,
        item_diff: {
          action: action,
          role: role
        }
    end

    context 'add' do
      let(:action) { Versions::RoleVersion::Actions[:add] }
      let(:role) { Types::User::Roles[:super_moderator] }
      subject! { version.apply_changes }

      it { expect(user_admin.reload).to be_super_moderator }
    end

    context 'remove' do
      let(:action) { Versions::RoleVersion::Actions[:remove] }
      let(:role) { Types::User::Roles[:admin] }
      subject! { version.apply_changes }

      it { expect(user_admin.reload).to_not be_admin }
    end
  end

  describe '#rollback_changes' do
    let(:version) do
      build :role_version,
        item: user_admin,
        item_diff: {
          action: action,
          role: role
        }
    end

    context 'add' do
      let(:action) { Versions::RoleVersion::Actions[:add] }
      let(:role) { Types::User::Roles[:admin] }
      subject! { version.rollback_changes }

      it { expect(user_admin.reload).to_not be_admin }
    end

    context 'remove' do
      let(:action) { Versions::RoleVersion::Actions[:remove] }
      let(:role) { Types::User::Roles[:super_moderator] }
      subject! { version.rollback_changes }

      it { expect(user_admin.reload).to be_super_moderator }
    end
  end

  describe 'permissions' do
    subject { Ability.new user }
    let(:user) { build_stubbed :user, roles: [role] }

    context 'admin' do
      let(:role) { :admin }

      describe 'admin roles' do
        it { is_expected.to be_able_to :manage_super_moderator_role, user }
        it { is_expected.to be_able_to :manage_video_super_moderator_role, user }
        it { is_expected.to be_able_to :manage_cosplay_moderator_role, user }
        it { is_expected.to be_able_to :manage_contest_moderator_role, user }
      end

      describe 'auto roles' do
        it { is_expected.to be_able_to :manage_completed_announced_animes_role, user }
      end

      describe 'super_moderator roles' do
        it { is_expected.to be_able_to :manage_forum_moderator_role, user }
        it { is_expected.to be_able_to :manage_review_moderator_role, user }
        it { is_expected.to be_able_to :manage_news_moderator_role, user }
        it { is_expected.to be_able_to :manage_article_moderator_role, user }
        it { is_expected.to be_able_to :manage_collection_moderator_role, user }
        it { is_expected.to be_able_to :manage_version_names_moderator_role, user }
        it { is_expected.to be_able_to :manage_version_texts_moderator_role, user }
        it { is_expected.to be_able_to :manage_version_moderator_role, user }
        it { is_expected.to be_able_to :manage_version_fansub_moderator_role, user }
        it { is_expected.to be_able_to :manage_trusted_version_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_version_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_names_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_texts_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_fansub_changer_role, user }
        it { is_expected.to be_able_to :manage_trusted_fansub_changer_role, user }
        it { is_expected.to be_able_to :manage_retired_moderator_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_abuse_reporter_role, user }
      end

      describe 'forum_moderator roles' do
        it { is_expected.to be_able_to :manage_censored_avatar_role, user }
        it { is_expected.to be_able_to :manage_censored_profile_role, user }
      end

      describe 'statistics_moderator roles' do
        it { is_expected.to be_able_to :manage_cheat_bot_role, user }
        it { is_expected.to be_able_to :manage_ignored_in_achievement_statistics_role, user }
      end
    end

    context 'super_moderator' do
      let(:role) { :super_moderator }

      describe 'admin roles' do
        it { is_expected.to_not be_able_to :manage_super_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_video_super_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_cosplay_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_contest_moderator_role, user }
      end

      describe 'auto roles' do
        it { is_expected.to_not be_able_to :manage_completed_announced_animes_role, user }
      end

      describe 'super_moderator roles' do
        it { is_expected.to be_able_to :manage_forum_moderator_role, user }
        it { is_expected.to be_able_to :manage_review_moderator_role, user }
        it { is_expected.to be_able_to :manage_news_moderator_role, user }
        it { is_expected.to be_able_to :manage_article_moderator_role, user }
        it { is_expected.to be_able_to :manage_collection_moderator_role, user }
        it { is_expected.to be_able_to :manage_version_names_moderator_role, user }
        it { is_expected.to be_able_to :manage_version_texts_moderator_role, user }
        it { is_expected.to be_able_to :manage_version_moderator_role, user }
        it { is_expected.to be_able_to :manage_version_fansub_moderator_role, user }
        it { is_expected.to be_able_to :manage_trusted_version_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_version_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_names_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_texts_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_fansub_changer_role, user }
        it { is_expected.to be_able_to :manage_trusted_fansub_changer_role, user }
        it { is_expected.to be_able_to :manage_retired_moderator_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_abuse_reporter_role, user }
      end

      describe 'forum_moderator roles' do
        it { is_expected.to be_able_to :manage_censored_avatar_role, user }
        it { is_expected.to be_able_to :manage_censored_profile_role, user }
      end

      describe 'statistics_moderator roles' do
        it { is_expected.to be_able_to :manage_cheat_bot_role, user }
        it { is_expected.to be_able_to :manage_ignored_in_achievement_statistics_role, user }
      end
    end

    context 'forum_moderator' do
      let(:role) { :forum_moderator }

      describe 'admin roles' do
        it { is_expected.to_not be_able_to :manage_super_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_video_super_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_cosplay_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_contest_moderator_role, user }
      end

      describe 'auto roles' do
        it { is_expected.to_not be_able_to :manage_completed_announced_animes_role, user }
      end

      describe 'super_moderator roles' do
        it { is_expected.to_not be_able_to :manage_forum_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_review_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_news_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_article_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_collection_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_names_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_texts_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_fansub_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_names_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_texts_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_retired_moderator_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_abuse_reporter_role, user }
      end

      describe 'forum_moderator roles' do
        it { is_expected.to be_able_to :manage_censored_avatar_role, user }
        it { is_expected.to be_able_to :manage_censored_profile_role, user }
      end

      describe 'statistics_moderator roles' do
        it { is_expected.to_not be_able_to :manage_cheat_bot_role, user }
        it { is_expected.to_not be_able_to :manage_ignored_in_achievement_statistics_role, user }
      end
    end

    context 'version_names_moderator' do
      let(:role) { :version_names_moderator }

      describe 'super_moderator roles' do
        it { is_expected.to_not be_able_to :manage_forum_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_review_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_news_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_article_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_collection_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_names_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_texts_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_fansub_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_version_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_names_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_texts_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_retired_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_abuse_reporter_role, user }
      end
    end

    context 'version_texts_moderator' do
      let(:role) { :version_texts_moderator }

      describe 'super_moderator roles' do
        it { is_expected.to_not be_able_to :manage_forum_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_review_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_news_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_article_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_collection_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_names_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_texts_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_fansub_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_names_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_texts_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_retired_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_abuse_reporter_role, user }
      end
    end

    context 'version_fansub_moderator' do
      let(:role) { :version_fansub_moderator }

      describe 'super_moderator roles' do
        it { is_expected.to_not be_able_to :manage_forum_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_review_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_news_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_article_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_collection_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_names_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_texts_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_fansub_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_names_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_texts_changer_role, user }
        it { is_expected.to be_able_to :manage_not_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_retired_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_abuse_reporter_role, user }
      end
    end

    context 'contest_moderator' do
      let(:role) { :contest_moderator }

      describe 'auto roles' do
        it { is_expected.to_not be_able_to :manage_completed_announced_animes_role, user }
      end

      describe 'statistics_moderator roles' do
        it { is_expected.to be_able_to :manage_cheat_bot_role, user }
        it { is_expected.to_not be_able_to :manage_completed_announced_animes_role, user }
        it { is_expected.to_not be_able_to :manage_ignored_in_achievement_statistics_role, user }
      end
    end

    context 'statistics_moderator' do
      let(:role) { :statistics_moderator }

      describe 'statistics_moderator roles' do
        it { is_expected.to_not be_able_to :manage_cheat_bot_role, user }
        it { is_expected.to_not be_able_to :manage_completed_announced_animes_role, user }
        it { is_expected.to be_able_to :manage_ignored_in_achievement_statistics_role, user }
      end
    end

    context 'user' do
      let(:user) { seed :user }

      describe 'admin roles' do
        it { is_expected.to_not be_able_to :manage_super_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_video_super_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_cosplay_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_contest_moderator_role, user }
      end

      describe 'super_moderator roles' do
        it { is_expected.to_not be_able_to :manage_forum_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_review_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_news_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_article_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_collection_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_version_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_version_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_names_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_texts_changer_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_trusted_fansub_changer_role, user }
        it { is_expected.to_not be_able_to :manage_retired_moderator_role, user }
        it { is_expected.to_not be_able_to :manage_not_trusted_abuse_reporter_role, user }
        it { is_expected.to_not be_able_to :manage_cheat_bot_role, user }
        it { is_expected.to_not be_able_to :manage_completed_announced_animes_role, user }
      end

      describe 'forum_moderator roles' do
        it { is_expected.to_not be_able_to :manage_censored_avatar_role, user }
        it { is_expected.to_not be_able_to :manage_censored_profile_role, user }
      end
    end
  end
end
