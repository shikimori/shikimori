describe NameMatches::BuildMatches do
  let(:service) { NameMatches::BuildMatches.new entry }
  let(:entry) do
    build :anime,
      id: id,
      kind: kind,
      name: 'Ootnik z Ootnik!',
      russian: 'Охотник!',
      aired_on: Date.parse('2000-01-01'),
      synonyms: [
        'Hunter x Hunter',
        'Hunters'
      ],
      english: [
        'English Hunter'
      ],
      japanese: [
        'ハンターxハンター'
      ]
  end

  let(:id) { 9999999 }
  let(:kind) { :tv }

  describe '#call' do
    subject(:name_matches) { service.call }

    it do
      is_expected.to have(24).items
      expect(name_matches.first).to be_kind_of NameMatch
      expect(name_matches.first).to be_new_record
      expect(name_matches.first).to be_valid
      expect(name_matches.first).to have_attributes(
        id: nil,
        phrase: 'ootnikzootnik!',
        group: 1,
        priority: 0,
        target: entry
      )
      expect(name_matches.map(&:phrase)).to eq [
        'ootnikzootnik!', 'ootnikzootnik!tv', 'ootnikzootnik!2000',
        'hunterxhuntertv', 'hunterxhunter2000',
        'hunterstv', 'hunters2000',
        'englishuntertv', 'englishunter2000',
        'ハンターxハンターtv', 'ハンターxハンター2000',
        'hunterxhunter', 'hunters', 'englishunter', 'ハンターxハンター',
        'ootnikzootnik', 'ootnikzootniktv', 'ootnikzootnik2000',
        'охотник!', 'охотник!tv', 'охотник!2000',
        'охотник', 'охотникtv', 'охотник2000'
      ]
    end

    describe 'predefined_name' do
      context 'matched' do
        let(:id) { 136 }

        it do
          is_expected.to have(25).items
          expect(name_matches.first).to have_attributes(
            phrase: 'охотникхохотник',
            group: 0
          )
          expect(name_matches.second).to have_attributes(
            phrase: 'ootnikzootnik!',
            group: 1
          )
        end
      end

      context 'not matched' do
        let(:id) { 9999 }

        it do
          is_expected.to have(24).items
          expect(name_matches.first).to have_attributes(
            phrase: 'ootnikzootnik!',
            group: 1
          )
        end
      end
    end

    describe 'priority' do
      context 'tv' do
        let(:kind) { :tv }
        it { expect(name_matches.first).to have_attributes priority: 0 }
      end

      context 'ova' do
        let(:kind) { :ova }
        it { expect(name_matches.first).to have_attributes priority: 1 }
      end
    end
  end
end
