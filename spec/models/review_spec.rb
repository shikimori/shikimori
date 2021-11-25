describe Review do
  describe 'associations' do
    it { is_expected.to belong_to :user }
    # it { is_expected.to belong_to(:anime).optional }
    # it { is_expected.to belong_to(:manga).optional }
    it { is_expected.to have_many(:abuse_requests).dependent :destroy }
    it { is_expected.to have_many :bans }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :body }
    # it { is_expected.to validate_presence_of :anime }
    # it { is_expected.to validate_presence_of :manga }
    it { is_expected.to validate_length_of(:body).is_at_least(described_class::MIN_BODY_SIZE) }
    # it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:anime_id) }
    # it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:manga_id) }
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:opinion)
        .in(*Types::Review::Opinion.values)
    end
  end

  describe 'scopes' do
    let(:anime) { create :anime }
    let!(:positive) { create :review, :positive, anime: anime }
    let!(:neutral) { create :review, :neutral, anime: anime, user: user_admin }
    let!(:negative) { create :review, :negative, anime: anime, user: user_day_registered }

    describe 'positive' do
      it { expect(Review.positive).to eq [positive] }
      it { expect(Review.neutral).to eq [neutral] }
      it { expect(Review.negative).to eq [negative] }
    end
  end

  describe 'callbacks' do
    describe '#fill_is_written_before_release' do
      subject { review.is_written_before_release }

      let(:review) do
        model = Review.new(
          anime: anime,
          manga: manga,
          body: 'a' * described_class::MIN_BODY_SIZE,
          user: user,
          opinion: 'positive',
          is_written_before_release: is_written_before_release
        )
        model.instance_variable_set :@custom_created_at, custom_created_at
        model.save
        model
      end
      let(:anime) { nil }
      let(:manga) { nil }
      let(:is_written_before_release) { nil }
      let(:custom_created_at) { nil }

      context 'anime' do
        let(:anime) { create :anime, status, released_on: released_on }
        let(:status) { :released }
        let(:released_on) { nil }

        context 'is set' do
          context 'true' do
            let(:is_written_before_release) { true }
            it { is_expected.to eq true }
          end

          context 'false' do
            let(:is_written_before_release) { false }
            it { is_expected.to eq false }
          end
        end

        context 'not set' do
          context 'released' do
            let(:status) { :released }

            context 'released_on is not set' do
              let(:released_on) { nil }
              it { is_expected.to eq false }
            end

            context 'released_on is set' do
              context 'released_on > now()' do
                let(:released_on) { Time.zone.tomorrow }
                it { is_expected.to eq true }

                context 'custom_created_at' do
                  context 'before released_on' do
                    let(:custom_created_at) { released_on - 2.days }
                    it { is_expected.to eq true }
                  end

                  context 'after released_on' do
                    let(:custom_created_at) { released_on + 2.days }
                    it { is_expected.to eq false }
                  end
                end
              end

              context 'released_on <= now()' do
                let(:released_on) { Time.zone.today }
                it { is_expected.to eq false }
              end
            end
          end

          context 'not released' do
            let(:status) { %i[anons ongoing].sample }
            it { is_expected.to eq true }
          end
        end
      end

      context 'manga' do
        let(:manga) { create :manga, status, released_on: released_on }
        let(:status) { :released }
        let(:released_on) { nil }

        context 'released' do
          let(:status) { :released }

          context 'released_on is not set' do
            let(:released_on) { nil }
            it { is_expected.to eq false }
          end

          context 'released_on is set' do
            context 'released_on > now()' do
              let(:released_on) { Time.zone.tomorrow }
              it { is_expected.to eq true }
            end

            context 'released_on <= now()' do
              let(:released_on) { Time.zone.today }
              it { is_expected.to eq false }
            end
          end
        end

        context 'not released' do
          let(:status) { %i[anons ongoing].sample }
          it { is_expected.to eq true }
        end

        context 'discontinued' do
          let(:status) { :discontinued }
          it { is_expected.to eq false }
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#anime? & #manga?, #db_entry, #db_entry_id' do
      subject { build :review, anime: anime, manga: manga }
      let(:anime) { nil }
      let(:manga) { nil }

      its(:anime?) { is_expected.to eq false }
      its(:manga?) { is_expected.to eq false }
      its(:db_entry) { is_expected.to be_nil }
      its(:db_entry_id) { is_expected.to be_nil }

      context 'anime' do
        let(:anime) { build_stubbed :anime }

        its(:anime?) { is_expected.to eq true }
        its(:manga?) { is_expected.to eq false }
        its(:db_entry) { is_expected.to eq anime }
        its(:db_entry_id) { is_expected.to eq anime.id }
      end

      context 'manga' do
        let(:manga) { build_stubbed :manga }

        its(:anime?) { is_expected.to eq false }
        its(:manga?) { is_expected.to eq true }
        its(:db_entry) { is_expected.to eq manga }
        its(:db_entry_id) { is_expected.to eq manga.id }
      end
    end

    describe '#html_body' do
      subject { build :review, body: body }
      let(:body) { '[b]zxc[/b]' }
      its(:html_body) { is_expected.to eq '<strong>zxc</strong>' }
    end

    describe '#db_entry_released_before?' do
      let(:anime) { build_stubbed :anime, status, released_on: released_on }
      subject { build :review, anime: anime }

      context 'released' do
        let(:status) { :released }

        context 'released_on is set' do
          context 'released_on > now()' do
            let(:released_on) { Time.zone.tomorrow }
            its(:db_entry_released_before?) { is_expected.to eq false }
          end

          context 'released_on <= now()' do
            let(:released_on) { Time.zone.today }
            its(:db_entry_released_before?) { is_expected.to eq true }
          end
        end
      end

      context 'not released' do
        let(:status) { %i[anons ongoing].sample }
        let(:released_on) { nil }
        its(:db_entry_released_before?) { is_expected.to eq false }
      end
    end

    describe '#cache_key_with_version' do
      include_context :timecop, '2021-08-01 15:44:03 +0300'

      let(:review) { build_stubbed :review, id: 1, user: user }
      let(:user) { build_stubbed :user, id: 2, rate_at: Time.zone.now }

      it do
        expect(review.cache_key_with_version).to eq(
          'reviews/1-20210801124403000000/user/2/1627821843'
        )
      end
    end

    describe '#written_before_release?' do
      let(:review) do
        build_stubbed :review,
          manga: manga,
          is_written_before_release: is_written_before_release
      end
      let(:is_written_before_release) { true }
      let(:manga) do
        build_stubbed :manga,
          status: status,
          aired_on: aired_on,
          released_on: released_on
      end
      let(:aired_on) { nil }
      let(:released_on) { nil }

      subject { review.written_before_release? }

      context 'ongoing' do
        let(:status) { :ongoing }

        context 'is_written_before_release' do
          context 'no aired_on' do
            it { is_expected.to eq true }
          end

          context 'aired_on > 1.year.ago' do
            let(:aired_on) { 13.months.ago }
            it { is_expected.to eq false }
          end

          context 'aired_on < 1.year.ago' do
            let(:aired_on) { 11.months.ago }
            it { is_expected.to eq true }
          end
        end
      end

      context 'not ongoing' do
        let(:status) { %i[anons released].sample }
        it { is_expected.to eq true }
      end
    end

    describe '#user_rate' do
      let(:review) { build_stubbed :review, anime: anime, manga: manga }
      let(:anime) { nil }
      let(:manga) { nil }

      subject { review.user_rate }

      context 'no rate' do
        it { is_expected.to be_nil }
      end

      context 'anime rate' do
        let(:anime) { create :anime }
        let!(:user_rate) { create :user_rate, target: anime, user: user }

        it { is_expected.to eq user_rate }
      end

      context 'manga rate' do
        let(:manga) { create :manga }
        let!(:user_rate) { create :user_rate, target: manga, user: user }

        it { is_expected.to eq user_rate }
      end
    end

    describe '#faye_channels' do
      let(:review) { build_stubbed :review }
      it { expect(review.faye_channels).to eq %W[/review-#{review.id}] }
    end

    describe '#locale' do
      its(:locale) { is_expected.to eq :ru }
    end
  end

  describe 'permissions' do
    subject { Ability.new user }

    context 'guest' do
      let(:user) { nil }
      let(:review) { build_stubbed :review }

      it { is_expected.to_not be_able_to :new, review }
      it { is_expected.to_not be_able_to :create, review }
      it { is_expected.to_not be_able_to :update, review }
      it { is_expected.to_not be_able_to :destroy, review }
    end

    context 'not review owner' do
      let(:user) { build_stubbed :user, :user, :day_registered }
      let(:user_2) { build_stubbed :user, :user, :day_registered }
      let(:review) { build_stubbed :review, user: user_2 }

      it { is_expected.to_not be_able_to :new, review }
      it { is_expected.to_not be_able_to :create, review }
      it { is_expected.to_not be_able_to :update, review }
      it { is_expected.to_not be_able_to :destroy, review }
    end

    context 'review owner' do
      let(:user) { build_stubbed :user, :user, :day_registered }
      let(:review) { build_stubbed :review, user: user }

      it { is_expected.to be_able_to :new, review }
      it { is_expected.to be_able_to :create, review }
      it { is_expected.to be_able_to :update, review }

      context 'user is registered < 1 day ago' do
        let(:user) { build_stubbed :user, :user }

        it { is_expected.to_not be_able_to :new, review }
        it { is_expected.to_not be_able_to :create, review }
        it { is_expected.to_not be_able_to :update, review }
      end

      context 'banned user' do
        let(:user) { build_stubbed :user, :banned, :day_registered }

        it { is_expected.to_not be_able_to :new, review }
        it { is_expected.to_not be_able_to :create, review }
        it { is_expected.to_not be_able_to :update, review }
      end
    end

    context 'forum moderator' do
      let(:user) { build_stubbed :user, :forum_moderator }
      let(:review) { build_stubbed :review, user: build_stubbed(:user) }
      it { is_expected.to be_able_to :manage, review }
    end
  end

  it_behaves_like :antispam_concern, :review
end
