describe NameMatches::BuildMatches do
  let(:service) { NameMatches::BuildMatches.new entry }
  let(:entry) do
    build :anime,
      id: id,
      kind: kind,
      name: 'Ootnik z Ootnik!',
      russian: 'Охотник!',
      aired_on: '2000-01-01',
      synonyms: [
        'Hunter x Hunter',
        'Hunters'
      ],
      english: 'English Hunter',
      japanese: 'ハンターxハンター'
  end

  let(:id) { 9_999_999 }
  let(:kind) { :tv }

  describe '#call' do
    subject(:name_matches) { service.call }

    it do
      expect(name_matches.map(&:phrase)).to eq %w[
        ootnikzootnik!
        ootnikzootnik!tv
        ootnikzootnik!2000
        hunterxhunter
        hunters
        englisunter
        ハンターxハンター
        hunterxhuntertv
        hunterxhunter2000
        hunterstv
        hunters2000
        englisuntertv
        englisunter2000
        ハンターxハンターtv
        ハンターxハンター2000
        ootnikzootnik
        ootnikzootniktv
        ootnikzootnik2000
        охотник!
        охотник!tv
        охотник!2000
        охотник
        охотникtv
        охотник2000
      ]
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
        it { expect(name_matches.first).to have_attributes priority: NameMatches::BuildMatches::PRIORITIES[:tv] }
      end

      context 'ova' do
        let(:kind) { :ova }
        it { expect(name_matches.first).to have_attributes priority: NameMatches::BuildMatches::DEFAULT_PRIORITY }
      end
    end

    context 'only name' do
      let(:entry) { build_stubbed :anime, :tv, id: id, name: name, russian: '' }
      let(:name) { 'JoJo no Kimyou na Bouken (2000)' }

      it do
        expect(name_matches.map(&:phrase)).to eq %w[
          jojonokimyonaboken2000
          jojonokimyonaboken2000tv
          jojonokimyonaboken
        ]
        expect(name_matches.first).to be_kind_of NameMatch
        expect(name_matches.first).to be_new_record
        expect(name_matches.first).to be_valid
        expect(name_matches.first).to have_attributes(
          id: nil,
          phrase: 'jojonokimyonaboken2000',
          group: 1,
          priority: 0,
          target: entry
        )
      end
    end
  end
end
