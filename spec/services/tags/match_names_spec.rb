describe Tags::MatchNames do
  subject do
    described_class.call(
      names: names,
      tags: tags,
      no_correct: no_correct
    )
  end

  context 'with correct' do
    let(:names) { ['Sword Art Online'] }
    let(:tags) { ['sword_art_online'] }
    let(:no_correct) { false }

    context 'has direct match' do
      let(:names) { ['Sword Art Online'] }
      it { is_expected.to eq 'sword_art_online' }
    end

    context 'has indirect match' do
      context 'long name' do
        let(:names) { ['Sword Art Online 2'] }
        let(:tags) { ['sword_art_online'] }

        it { is_expected.to eq 'sword_art_online' }
      end

      context 'short name' do
        let(:names) { ['Sword 2'] }
        let(:tags) { ['sword'] }
        it { is_expected.to be_nil }
      end
    end
  end

  context 'without correct' do
    let(:tags) { ['sword_art_online'] }
    let(:no_correct) { true }

    context 'has direct match' do
      let(:names) { ['Sword Art Online'] }
      it { is_expected.to eq 'sword_art_online' }
    end

    context 'has indirect match' do
      let(:names) { ['Sword Art Online 2'] }
      it { is_expected.to be_nil }
    end
  end
end
