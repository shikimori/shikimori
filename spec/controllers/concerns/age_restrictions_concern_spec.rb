describe AgeRestrictionsConcern, type: :controller do
  kind = %w[anime topic collection].sample
  # kind = 'topic'

  describe "#{kind.pluralize.humanize}Controller".constantize do
    case kind
      when 'topic'
        let(:entry) { create :topic, forum: offtopic_forum, is_censored: is_censored }
        let(:make_request) do
          get :show,
            params: {
              id: entry.to_param,
              forum: offtopic_forum.to_param
            }
        end
        let(:make_rss_request) { nil }
        let(:make_xhr_request) { nil }
      when 'collection'
        let(:entry) do
          create :collection, :published, :with_topics,
            user: user,
            is_censored: is_censored
        end

        let(:make_request) { get :show, params: { id: entry.to_param } }
        let(:make_rss_request) { nil }
        let(:make_xhr_request) { nil }
      else
        let(:entry) { create kind.to_sym, is_censored: is_censored }
        let(:make_request) { get :show, params: { id: entry.id } }
        let(:make_rss_request) { get :show, format: :rss, params: { id: entry.id } }
        let(:make_xhr_request) { get :tooltip, xhr: true, params: { id: entry.id } }
      end

    context 'guest' do
      context 'censored' do
        let(:is_censored) { true }

        it { expect(make_request).to render_template 'pages/age_restricted' }
        it { expect(make_rss_request).to_not render_template 'pages/age_restricted' }
        it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }

        describe 'AgeRestricted exception' do
          before { bypass_rescue }
          it { expect { make_request }.to raise_error AgeRestricted }
          it { expect { make_rss_request }.to_not raise_error }
          it { expect { make_xhr_request }.to_not raise_error }
        end
      end

      context 'not censored' do
        let(:is_censored) { false }

        it { expect(make_request).to_not render_template 'pages/age_restricted' }
        it { expect(make_rss_request).to_not render_template 'pages/age_restricted' }
        it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }

        describe 'AgeRestricted exception' do
          before { bypass_rescue }
          it { expect { make_request }.to_not raise_error }
          it { expect { make_rss_request }.to_not raise_error }
          it { expect { make_xhr_request }.to_not raise_error }
        end
      end
    end

    context 'authenticated' do
      include_context :authenticated

      let(:user) { create :user, birth_on: birth_on, preferences: preferences }
      let(:birth_on) { nil }
      let(:preferences) { nil }

      context 'birth_on not set' do
        context 'censored' do
          let(:is_censored) { true }
          it { expect(make_request).to render_template 'pages/age_restricted' }
        end

        context 'not censored' do
          let(:is_censored) { false }
          it { expect(make_request).to_not render_template 'pages/age_restricted' }
        end
      end

      context 'age below 18' do
        let(:birth_on) { 18.years.ago + 1.day }

        context 'censored' do
          let(:is_censored) { true }
          it { expect(make_request).to render_template 'pages/age_restricted' }
        end

        context 'not censored' do
          let(:is_censored) { false }
          it { expect(make_request).to_not render_template 'pages/age_restricted' }
        end
      end

      context 'age above 18' do
        let(:birth_on) { 18.years.ago - 1.day }

        context 'censored' do
          let(:is_censored) { true }
          it { expect(make_request).to render_template 'pages/age_restricted' }
        end

        context 'not censored' do
          let(:is_censored) { false }
          it { expect(make_request).to_not render_template 'pages/age_restricted' }
        end

        context 'view censored preference set' do
          let(:preferences) { create :user_preferences, is_view_censored: true }

          context 'censored' do
            let(:is_censored) { true }
            it { expect(make_request).to_not render_template 'pages/age_restricted' }
          end

          context 'not censored' do
            let(:is_censored) { false }
            it { expect(make_request).to_not render_template 'pages/age_restricted' }
          end
        end
      end
    end
  end
end
