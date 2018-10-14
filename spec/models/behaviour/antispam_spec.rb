describe Antispam do
  include_context :timecop
  let(:user) { seed :user }

  context 'by interval' do
    let!(:comment) { create :comment, created_at: created_at, user: user }
    let(:comment_2) { build :comment, :with_antispam, user: user }

    let(:save) { comment_2.save }

    context 'created before interval' do
      let(:created_at) { (Comment.antispam_options.first[:interval] - 1.second).ago }

      it do
        expect { save }.to_not change Comment, :count
        expect(comment_2.errors[:base]).to eq [
          'Защита от спама. Попробуйте снова через 1 секунду'
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
        it { expect { save }.to change(Comment, :count).by 1 }
      end
    end

    context 'created after interval' do
      let(:created_at) { (Comment.antispam_options.first[:interval] + 1.second).ago }
      it { expect { save }.to change(Comment, :count).by 1 }
    end
  end
end
