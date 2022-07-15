=begin
describe AgeRestrictionsConcern, type: :controller do
  describe AnimesCollectionController do
    include AgeRestrictionsConcern

    describe 'anime' do
      # before { allow(controller).to receive(:verify_age_restricted!).with([entry_1, entry_2]) }

      let!(:entry_1) { create :anime, is_censored: true }
      let!(:entry_2) { create :anime, is_censored: true }
      let(:make_request) { get :index, params: { klass: 'anime' } }

      describe '#index' do
        it do
          bypass_rescue
          expect{ make_request }.to raise_error AgeRestricted
        end
      end
    end
  end
end
=end

describe AgeRestrictionsConcern, type: :controller do
  let(:current_user) { nil }

  %w[anime topic collection].each do |entry|
    describe "#{entry.pluralize.humanize}Controller".constantize do
      context "#{entry} show page" do
        case entry
          when 'topic'
            let(:anime) { create :anime, is_censored: is_censored }
            let(:anime_topic) { create :topic, forum: animanga_forum, linked: anime, is_censored: is_censored }

            let(:make_request) do
              get :show,
                params: {
                  id: anime_topic.to_param,
                  forum: animanga_forum.to_param,
                  linked_type: 'anime',
                  linked_id: anime.to_param
                }
            end
            let(:make_rss_request) { nil }
            let(:make_xhr_request) { nil }
          when 'collection'
            let(:collection) do
              create :collection, :published, :with_topics,
                user: user,
                is_censored: is_censored
            end

            let(:make_request) { get :show, params: { id: collection.to_param } }
            let(:make_rss_request) { nil }
            let(:make_xhr_request) { nil }
          else
            let(entry.to_sym) { create entry.to_sym, is_censored: is_censored }
            let(:make_request) { get :show, params: { id: send(entry).id } }
            let(:make_rss_request) { get :show, format: :rss, params: { id: send(entry).id } }
            let(:make_xhr_request) { get :tooltip, xhr: true, params: { id: send(entry).id } }
          end

        context 'guest user' do
          context 'censored' do
            let(:is_censored) { true }

            it do
              bypass_rescue
              expect { make_request }.to raise_error AgeRestricted
              expect { make_rss_request }.to_not raise_error
              expect { make_xhr_request }.to_not raise_error
            end

            it { expect(make_request).to render_template 'pages/age_restricted' }
            it { expect(make_rss_request).to_not render_template 'pages/age_restricted' }
            it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }

            it do
              make_request
              expect(response.body).to include('Авторизуйся')
            end
          end

          context 'not censored' do
            let(:is_censored) { false }

            it { expect(make_request).to_not render_template 'pages/age_restricted' }
            it { expect(make_rss_request).to_not render_template 'pages/age_restricted' }
            it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }

            it do
              bypass_rescue
              expect { make_request }.to_not raise_error
              expect { make_rss_request }.to_not raise_error
              expect { make_xhr_request }.to_not raise_error
            end
          end
        end

        context 'logged in user' do
          let(:user_stub) { create :user, birth_on: birth_on, preferences: preferences }
          before { allow(controller).to receive(:current_user) { user_stub } }
          before { allow(controller).to receive(:user_signed_in?) { true } }
          before { user_stub.define_singleton_method(:url) { '' } }
          before { user_stub.define_singleton_method(:unread_messages_url) { '' } }
          before { user_stub.define_singleton_method(:show_contest_link?) { '' } }
          before { user_stub.define_singleton_method(:unvoted_contests) { '' } }

          let(:birth_on) { nil }
          let(:preferences) { nil }

          context 'without age' do
            context 'censored' do
              let(:is_censored) { true }

              it do
                bypass_rescue
                expect { make_request }.to raise_error AgeRestricted
                expect { make_xhr_request }.to_not raise_error
              end

              it do
                make_request
                expect(response.body).to include('Пожалуйста, укажи свою дату рождения')
              end

              it { expect(make_request).to render_template 'pages/age_restricted' }
              it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }
            end

            context 'not censored' do
              let(:is_censored) { false }

              it { expect(make_request).to_not render_template 'pages/age_restricted' }
              it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }

              it do
                bypass_rescue
                expect { make_request }.to_not raise_error
                expect { make_xhr_request }.to_not raise_error
              end
            end
          end

          context 'underage' do
            let(:birth_on) { Time.zone.today - 10.years }

            context 'censored' do
              let(:is_censored) { true }

              it do
                bypass_rescue
                expect { make_request }.to raise_error AgeRestricted
                expect { make_xhr_request }.to_not raise_error
              end

              it do
                make_request
                expect(response.body).to include('меньше 18')
              end

              it { expect(make_request).to render_template 'pages/age_restricted' }
              it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }
            end

            context 'not censored' do
              let(:is_censored) { false }

              it { expect(make_request).to_not render_template 'pages/age_restricted' }
              it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }

              it do
                bypass_rescue
                expect { make_request }.to_not raise_error
                expect { make_xhr_request }.to_not raise_error
              end
            end
          end

          context 'age above 18' do
            let(:birth_on) { Time.zone.today - 18.years }

            context 'censored' do
              let(:is_censored) { true }

              it do
                bypass_rescue
                expect { make_request }.to raise_error AgeRestricted
                expect { make_xhr_request }.to_not raise_error
              end

              it do
                make_request
                expect(response.body).to include('Включить отображение 18+ контента?')
              end

              it { expect(make_request).to render_template 'pages/age_restricted' }
              it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }
            end

            context 'not censored' do
              let(:is_censored) { false }

              it { expect(make_request).to_not render_template 'pages/age_restricted' }
              it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }

              it do
                bypass_rescue
                expect { make_request }.to_not raise_error
                expect { make_xhr_request }.to_not raise_error
              end
            end

            context 'view censored preference set' do
              let(:preferences) { create :user_preferences, is_view_censored: true }

              context 'censored' do
                let(:is_censored) { true }

                it do
                  bypass_rescue
                  expect { make_request }.to_not raise_error
                  expect { make_xhr_request }.to_not raise_error
                end

                it { expect(make_request).to_not render_template 'pages/age_restricted' }
                it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }
              end

              context 'not censored' do
                let(:is_censored) { false }

                it { expect(make_request).to_not render_template 'pages/age_restricted' }
                it { expect(make_xhr_request).to_not render_template 'pages/age_restricted' }

                it do
                  bypass_rescue
                  expect { make_request }.to_not raise_error
                  expect { make_xhr_request }.to_not raise_error
                end
              end
            end
          end
        end
      end
    end
  end
end
