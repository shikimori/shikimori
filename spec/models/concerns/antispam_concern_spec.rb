describe AntispamConcern do
  include_context :timecop
  let(:user) { seed :user }

  context 'interval' do
    let!(:club) { create :club, created_at: created_at, owner: user }
    let(:club_2) { build :club, :with_antispam, owner: user }

    let(:save) { club_2.save }

    context 'created before interval' do
      let(:created_at) { (Club.antispam_options.first[:interval] - 1.second).ago }

      it do
        expect { save }.to_not change Club, :count
        expect(club_2.errors[:base]).to eq [
          'Защита от спама. Попробуйте снова через 1 секунду'
        ]
      end

      context '#wo_antispam' do
        let(:save) { Club.wo_antispam { club_2.save } }
        it { expect { save }.to change(Club, :count).by 1 }
      end

      context '#create_wo_antispam!' do
        before { allow_any_instance_of(Club).to receive :add_to_index }
        let(:club_3) { Club.create_wo_antispam! club_2.attributes }
        it { expect(club_3).to be_persisted }
      end

      context '#disable_antispam!' do
        before { club_2.disable_antispam! }
        it { expect { save }.to change(Club, :count).by 1 }
      end
    end

    context 'created after interval' do
      let(:created_at) { (Club.antispam_options.first[:interval] + 1.second).ago }
      it { expect { save }.to change(Club, :count).by 1 }
    end
  end

  context 'per_day' do
  end
end
