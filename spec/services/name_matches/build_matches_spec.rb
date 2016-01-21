describe NameMatches::BuildMatches do
  let(:service) { NameMatches::BuildMatches.new entry }
  let(:entry) do
    build_stubbed :anime,
      id: id,
      kind: kind,
      name: 'My anime',
      synonyms: [
        'My little anime',
        'My : little anime',
        'My Little Anime',
        'MyAnim'
      ]
  end

  let(:id) { 9999 }
  let(:kind) { :tv }

  describe '#call' do
    subject(:name_matches) { service.call }

    it do
      is_expected.to have(5).items
      expect(name_matches.first).to be_kind_of NameMatch
      expect(name_matches.first).to be_new_record
      expect(name_matches.first).to be_valid
      expect(name_matches.first).to have_attributes(
        id: nil,
        phrase: 'myanime',
        group: 1,
        priority: 0,
        target: entry
      )
      expect(name_matches.map(&:phrase)).to eq [
        'myanime', 'mylittleanime', 'myanim', 'littleanime', 'littleanimetv'
      ]
    end

    describe 'predefined_name' do
      context 'matched' do
        let(:id) { 136 }

        it do
          is_expected.to have(6).items
          expect(name_matches.first).to have_attributes(
            phrase: 'охотникхохотник',
            group: 0
          )
          expect(name_matches.second).to have_attributes(
            phrase: 'myanime',
            group: 1
          )
        end
      end

      context 'not matched' do
        let(:id) { 9999 }

        it do
          is_expected.to have(5).items
          expect(name_matches.first).to have_attributes(
            phrase: 'myanime',
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
