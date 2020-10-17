describe AntispamConcern do
  include_context :timecop
  let(:user) { seed :user }

  context 'interval' do
    let!(:comment_1) { create :comment, created_at: created_at, user: user }
    let(:comment_2) { build :comment, :with_antispam, user: user_2 }
    let(:user_2) { user }

    context 'created before interval' do
      let(:created_at) { (Comment.antispam_options.first[:interval] - 1.second).ago }

      it do
        expect { comment_2.save }.to_not change Comment, :count
        expect(comment_2.errors[:base]).to eq [
          'Защита от спама. Попробуй снова через 1 секунду.'
        ]
      end

      context '#wo_antispam' do
        let(:save) { Comment.wo_antispam { comment_2.save } }
        it { expect { save }.to change(Comment, :count).by 1 }
      end

      context '#create_wo_antispam!' do
        let(:comment_3) { Comment.create_wo_antispam! comment_2.attributes }
        it { expect(comment_3).to be_persisted }
      end

      context '#disable_antispam!' do
        before { comment_2.disable_antispam! }
        it { expect { comment_2.save }.to change(Comment, :count).by 1 }
      end

      context 'created by another user' do
        let(:user_2) { create :user }
        it { expect { comment_2.save }.to change(Comment, :count).by 1 }
      end
    end

    context 'created after interval' do
      let(:created_at) { (Comment.antispam_options.first[:interval] + 1.second).ago }
      it { expect { comment_2.save }.to change(Comment, :count).by 1 }
    end
  end

  context 'per_day' do
    let!(:club_1) { create :club, created_at: created_at, owner: user }
    let!(:club_2) { create :club, created_at: created_at, owner: user }
    let(:club_3) { build :club, :with_antispam, owner: user_2 }

    let(:user_2) { user }

    context 'created more times than limited' do
      let(:created_at) { (AntispamConcern::DAY_DURATION - 1.second).ago }

      it do
        expect { club_3.save }.to_not change Club, :count
        expect(club_3.errors[:base]).to eq [
          'Защита от спама. Подожди до завтра.'
        ]
      end

      context 'created by another user' do
        let(:user_2) { create :user }
        it { expect { club_3.save }.to change(Club, :count).by 1 }
      end
    end

    context 'created less times than limited' do
      let(:created_at) { (AntispamConcern::DAY_DURATION + 1.second).ago }
      let!(:club_1) { create :club, created_at: created_at, owner: user }
      let(:club_3) { build :club, :with_antispam, owner: user }

      it { expect { club_3.save }.to change(Club, :count).by 1 }
    end
  end
end
