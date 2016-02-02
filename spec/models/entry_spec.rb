require 'cancan/matchers'

describe Entry do
  describe 'relations' do
    it { is_expected.to belong_to :forum }
    it { is_expected.to belong_to :linked }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :views }
    it { is_expected.to have_many :messages }
    it { is_expected.to have_many :topic_ignores }
  end

  context 'hooks' do
    # let!(:images) { create_list :user_image, 4, linked_type: Entry.name }
    # let!(:entry) { create :news_topic, body: 'text', value: "#{images[0].id},#{images[1].id}" }

    # describe 'append_wall' do
      # it 'wall tag is appended' do
        # expect(entry.body).to eq "text\n[wall][url=#{images[0].image.url :original, false}][poster]#{images[0].image.url :preview, false}[/poster][/url][url=#{images[1].image.url :original, false}][poster]#{images[1].image.url :preview, false}[/poster][/url][/wall]"
      # end
    # end

    # describe 'destroy_images' do
      # it 'all images are destroyed' do
        # expect{entry.destroy}.to change(UserImage, :count).by -2
      # end
    # end

    # describe '#claim_images' do
      # it 'all images are claimed' do
        # expect(images[0].reload.linked).to eq entry
      # end
    # end

    # describe '#unclaim_images' do
      # let!(:entry) { create :news_topic, body: 'text', value: "#{images[0].id},#{images[1].id},#{images[2].id},#{images[3].id}" }

      # it 'unused images are destroyed' do
        # expect {
          # entry.user_image_ids = [images[0].id, images[1].id]
          # entry.save
        # }.to change(UserImage, :count).by -2
      # end
    # end
  end

  describe 'instance methods' do
    let(:user) { create :user }
    let(:user2) { create :user }
    let(:entry) { create :entry, user: user }

    # describe '#user_images' do
      # let(:images) { create_list :user_image, 3, user: user }
      # let(:entry) { create :entry, user: user, value: "#{images[0].id},#{images[2].id},#{images[1].id}" }

      # it 'returns user images stored in value in correct order' do
        # expect(entry.user_images).to eq [images[0], images[2], images[1]]
      # end
    # end

    context 'comment was deleted' do
      it 'updated_at is set to created_at of last comment' do
        first = second = third = nil
        Comment.wo_antispam do
          first = create :comment, commentable: entry, created_at: 2.days.ago, body: 'first'
          second = create :comment, commentable: entry, created_at: 1.day.ago, body: 'second'
          third = create :comment, commentable: entry, created_at: 30.minutes.ago, body: 'third'
        end
        third.destroy
        expect(first.commentable.reload.updated_at.to_i).to eq(second.created_at.to_i)
      end
    end

    describe 'comments selected with viewed flag' do
      before do
        @comment = create :comment, commentable: entry, user: user
      end

      it 'false' do
        expect(entry.comments.with_viewed(user2).first.viewed?).to be_falsy
      end

      it 'true' do
        create :comment_view, comment: @comment, user: user2
        expect(entry.comments(user2).first.viewed?).to be_truthy
      end
    end

    describe '#original_body & #appended_body' do
      let(:entry) { build :entry, body: body, generated: is_generated }
      let(:body) { 'test[wall][/wall]' }

      context 'entry' do
        let(:is_generated) { false }

        context 'with wall' do
          it { expect(entry.original_body).to eq 'test' }
          it { expect(entry.appended_body).to eq '[wall][/wall]' }
        end

        context 'without wall' do
          let(:body) { 'test' }
          it { expect(entry.original_body).to eq 'test' }
          it { expect(entry.appended_body).to eq '' }
        end
      end

      context 'generated' do
        let(:is_generated) { true }

        context 'with wall' do
          it { expect(entry.original_body).to eq 'test[wall][/wall]' }
          it { expect(entry.appended_body).to eq '' }
        end

        context 'without wall' do
          let(:body) { 'test' }
          it { expect(entry.original_body).to eq 'test' }
          it { expect(entry.appended_body).to eq '' }
        end
      end
    end

    describe 'wall_images' do
      let!(:user_image_1) { create :user_image }
      let!(:user_image_2) { create :user_image }
      let(:entry) do
        build :entry, body: "text\n[wall]\
[url=#{ImageUrlGenerator.instance.url user_image_2, :original}][poster=#{user_image_2.id}][/url]\
[url=#{ImageUrlGenerator.instance.url user_image_1, :original}][poster=#{user_image_1.id}][/url]\
[/wall]"
      end

      it { expect(entry.wall_images).to eq [user_image_2, user_image_1] }
    end

    describe '#wall_ids=' do
      let(:user_image_1) { create :user_image }
      let(:user_image_2) { create :user_image }

      before { entry.wall_ids = [user_image_1.id.to_s, user_image_2.id.to_s] }

      it do
        expect(entry.value).to eq "#{user_image_1.id},#{user_image_2.id}"
        expect(entry.body).to eq "#{entry.original_body}
[wall]\
[url=#{ImageUrlGenerator.instance.url user_image_1, :original}][poster=#{user_image_1.id}][/url]\
[url=#{ImageUrlGenerator.instance.url user_image_2, :original}][poster=#{user_image_2.id}][/url]\
[/wall]"
      end
    end
  end

  context 'permissions' do
    let(:user) { build_stubbed :user, :user, :day_registered }
    let(:entry) { build_stubbed :entry, user: entry_user, created_at: created_at }

    let(:entry_user) { user }
    let(:created_at) { Time.zone.now }

    subject { Ability.new user }

    context 'entry owner' do
      context 'not banned' do
        it { is_expected.to be_able_to :new, entry }
        it { is_expected.to be_able_to :create, entry }
        it { is_expected.to be_able_to :update, entry }

        context 'old entry' do
          let(:created_at) { 4.hours.ago - 1.minute }
          it { is_expected.to_not be_able_to :destroy, entry }
        end

        context 'new entry' do
          let(:created_at) { 4.hours.ago + 1.minute }
          it { is_expected.to be_able_to :destroy, entry }
        end
      end

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user, created_at: 23.hours.ago }

        it { is_expected.to_not be_able_to :new, entry }
        it { is_expected.to_not be_able_to :create, entry }
        it { is_expected.to_not be_able_to :update, entry }
        it { is_expected.to_not be_able_to :destroy, entry }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :banned, :day_registered }

        it { is_expected.to_not be_able_to :new, entry }
        it { is_expected.to_not be_able_to :create, entry }
        it { is_expected.to_not be_able_to :update, entry }
        it { is_expected.to_not be_able_to :destroy, entry }
      end
    end

    context 'forum moderator' do
      let(:user) { build_stubbed :user, :moderator }

      context 'common topic' do
        it { is_expected.to be_able_to :manage, entry }
      end

      context 'generated topic' do
        let(:entry) { build_stubbed :club_topic, user: entry_user, created_at: created_at }
        it { is_expected.to_not be_able_to :manage, entry }
      end

      context 'generated review topic' do
        let(:entry) { build_stubbed :review_topic, user: entry_user, created_at: created_at }
        it { is_expected.to be_able_to :manage, entry }
      end
    end

    context 'user' do
      let(:entry_user) { build_stubbed :user, :day_registered }

      it { is_expected.to_not be_able_to :new, entry }
      it { is_expected.to_not be_able_to :create, entry }
      it { is_expected.to_not be_able_to :update, entry }
      it { is_expected.to_not be_able_to :destroy, entry }
    end

    context 'guest' do
      let(:user) { nil }

      it { is_expected.to_not be_able_to :new, entry }
      it { is_expected.to_not be_able_to :create, entry }
      it { is_expected.to_not be_able_to :update, entry }
      it { is_expected.to_not be_able_to :destroy, entry }
    end
  end
end
