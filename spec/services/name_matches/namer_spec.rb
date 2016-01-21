describe NameMatches::Namer do
  let(:service) { NameMatches::Namer.instance }

  let(:entry) do
    build :anime,
      id: id,
      kind: kind,
      name: 'Ootnik z Ootnik!',
      russian: 'Охотник!',
      aired_on: aired_on,
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

  let(:id) { 99999999999 }
  let(:kind) { :tv }
  let(:aired_on) { Date.parse '2000-01-01' }

  describe '#predefined' do
    context 'matched' do
      let(:id) { 136 }
      it { expect(service.predefined entry).to eq ['охотник х охотник'] }
    end

    context 'matched' do
      let(:id) { 9999999 }
      it { expect(service.predefined entry).to eq [] }
    end
  end

  describe '#name' do
    context 'with aired_on' do
      let(:aired_on) { Date.parse '2005-01-01' }
      it do
        expect(service.name entry).to eq [
          'ootnik z ootnik!', 'ootnik z ootnik! tv', 'ootnik z ootnik! 2005'
        ]
      end
    end

    context 'without aired_on' do
      let(:aired_on) { nil }
      it do
        expect(service.name entry).to eq [
          'ootnik z ootnik!', 'ootnik z ootnik! tv'
        ]
      end
    end
  end

  describe '#alt' do
    it do
      expect(service.alt entry).to eq [
        'hunter x hunter tv', 'hunter x hunter 2000',
        'hunters tv', 'hunters 2000',
        'englis hunter tv', 'englis hunter 2000',
        'ハンターxハンター tv', 'ハンターxハンター 2000'
      ]
    end
  end

  describe '#alt2' do
    it do
      expect(service.alt2 entry).to eq [
        'hunter x hunter', 'hunters', 'englis hunter', 'ハンターxハンター'
      ]
    end
  end

  describe '#alt3' do
    it do
      expect(service.alt3 entry).to eq [
        'ootnik z ootnik!', 'ootnik z ootnik! tv', 'ootnik z ootnik! 2000',
        'hunter x hunter', 'hunters', 'englis hunter', 'ハンターxハンター',
        'hunter x hunter tv', 'hunter x hunter 2000',
        'hunters tv', 'hunters 2000',
        'englis hunter tv', 'englis hunter 2000',
        'ハンターxハンター tv', 'ハンターxハンター 2000',
        'ootnik z ootnik', 'ootnik z ootnik tv',
        'ootnik z ootnik 2000'
      ]
    end
  end

  describe '#russian' do
    it do
      # expect(service.russian entry).to eq [
      # ]
    end
  end
end
