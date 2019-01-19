describe Tags::MatchNames do
  subject do
    described_class.call(
      names: names,
      tags_variants: tags_variants
    )
  end

  let(:tags_variants) { Tags::GenerateVariants.call tags }

  context 'with correct' do
    let(:names) { ['Sword Art Online'] }
    let(:tags) { ['sword_art_online', 'Sword Art Online', 'sword art online'] }
    let(:no_correct) { false }

    context 'has match' do
      [
        'sword art online',
        'Sword Art Online',
        'Sword Art Online II',
        'Sword Art Online ova',
        "Sword 'Art' Online",
        'Sword "Art" Online',
        'Sword_Art_Online',
        'sword_art_online',
        'sword art online!',
        'sword art online!!',
        'sword_art_online: zxc',
        'sword_art_online - zxc'
      ].each do |name|
        context name do
          let(:names) { [name] }
          it { is_expected.to eq tags }
        end
      end
    end

    context 'no match' do
      [
        'sword art onlin',
        'sword art online bla bla',
        'bla bla',
        'art online'
      ].each do |name|
        context name do
          let(:names) { [name] }
          it { is_expected.to eq [] }
        end
      end
    end

    context 'has indirect match' do
      context 'long name' do
        let(:names) { ['Sword Art Online 2'] }
        let(:tags) { ['sword_art_online'] }

        it { is_expected.to eq ['sword_art_online'] }
      end

      context 'short name' do
        let(:names) { ['sword z'] }
        let(:tags) { ['sword'] }
        it { is_expected.to eq [] }
      end
    end

    context 'with !' do
      let(:names) { ['working!!'] }
      let(:tags) { ['working!'] }

      it { is_expected.to eq ['working!'] }
    end
  end
end
