describe Studios do
  let(:query) { Studios.instance }

  describe '[]' do
    let!(:studio) { create :studio }
    it do
      expect(query[studio.id]).to eq studio
    end
  end

  describe '#reset' do
    let(:studio_id) { 999_999_999 }

    it do
      expect(query[studio_id]).to be_nil
      studio = create :studio, id: studio_id
      expect(query[studio_id]).to be_nil

      query.reset

      expect(query[studio_id]).to eq studio
    end
  end
end
