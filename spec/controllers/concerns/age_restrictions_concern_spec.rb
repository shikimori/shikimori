CONTROLLER_NAMES = %w[
  AnimesController
  MangasController
  TopicsController
]

describe AgeRestrictionsConcern, type: :controller do
  CONTROLLER_NAMES.each do |controller|
    describe controller.constantize do
      it 'includes AgeRestrictionsConcern' do
        expect(controller.constantize.ancestors.include? AgeRestrictionsConcern).to be(true)
      end
    end
  end

  let(:current_user) { nil }

  %w[anime manga topic].each do |entry|
    describe "#{entry.pluralize.humanize}Controller".constantize do
      include AgeRestrictionsConcern

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
          when 'collection'
            let(:collection) do
              create :collection, :published, :with_topics,
                kind: Types::Collection::Kind[type],
                user: user,
                is_censored: is_censored # почему-то не обновляется, надо чинить
            end

            let(:type) { %i[anime manga ranobe].sample }
            let(:make_request) { get :show, params: { id: collection.to_param } }
          else
            let(entry.to_sym) { create entry.to_sym, is_censored: is_censored }
            let(:make_request) { get :show, params: { id: send(entry).id } }
          end

        context 'guest user' do
          context 'censored' do
            let(:is_censored) { true }

            it do
              bypass_rescue
              expect { make_request }.to raise_error AgeRestricted
            end

            it { expect(make_request).to render_template 'pages/age_restricted' }

            it do
              make_request
              expect(response.body).to include('Авторизуйся')
            end
          end

          context 'not censored' do
            let(:is_censored) { false }

            it { expect(make_request).to_not render_template 'pages/age_restricted' }

            it do
              bypass_rescue
              expect { make_request }.to_not raise_error
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
              end

              it do
                make_request
                expect(response.body).to include('Пожалуйста, укажи свою дату рождения')
              end

              it { expect(make_request).to render_template 'pages/age_restricted' }
            end

            context 'not censored' do
              let(:is_censored) { false }

              it { expect(make_request).to_not render_template 'pages/age_restricted' }

              it do
                bypass_rescue
                expect { make_request }.to_not raise_error
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
              end

              it do
                make_request
                expect(response.body).to include('меньше 18')
              end

              it { expect(make_request).to render_template 'pages/age_restricted' }
            end

            context 'not censored' do
              let(:is_censored) { false }

              it { expect(make_request).to_not render_template 'pages/age_restricted' }

              it do
                bypass_rescue
                expect { make_request }.to_not raise_error
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
              end

              it do
                make_request
                expect(response.body).to include('Включить отображение 18+ контента?')
              end

              it { expect(make_request).to render_template 'pages/age_restricted' }
            end

            context 'not censored' do
              let(:is_censored) { false }

              it { expect(make_request).to_not render_template 'pages/age_restricted' }

              it do
                bypass_rescue
                expect { make_request }.to_not raise_error
              end
            end

            context 'view censored preference set' do
              let(:preferences) { create :user_preferences, is_view_censored: true }

              context 'censored' do
                let(:is_censored) { true }

                it do
                  bypass_rescue
                  expect { make_request }.to_not raise_error
                end

                it { expect(make_request).to_not render_template 'pages/age_restricted' }
              end

              context 'not censored' do
                let(:is_censored) { false }

                it { expect(make_request).to_not render_template 'pages/age_restricted' }

                it do
                  bypass_rescue
                  expect { make_request }.to_not raise_error
                end
              end
            end
          end
        end
      end
    end
  end
end
