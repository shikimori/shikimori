describe Publishers do
  let(:query) { Publishers.instance }

  describe '[]' do
    let!(:publisher) { create :publisher }
    it do
      expect(query[publisher.id]).to eq publisher
    end
  end

  describe '#reset' do
    let(:publisher_id) { 999_999_999 }

    it do
      expect(query[publisher_id]).to be_nil
      publisher = create :publisher, id: publisher_id
      expect(query[publisher_id]).to be_nil

      query.reset

      expect(query[publisher_id]).to eq publisher
    end
  end
end
