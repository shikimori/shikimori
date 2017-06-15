shared_examples :touch_related_in_db_entry do |db_entry|
  describe '#touch_related' do
    let(:model) { create db_entry }
    before do
      allow(DbEntries::TouchRelated).to receive :perform_async
    end
    subject! do
      db_entry.to_s.capitalize.constantize
        .find(model.id)
        .update(field => 'test 123456')
    end

    context 'russian' do
      let(:field) { :russian }
      it { expect(DbEntries::TouchRelated).to have_received(:perform_async).with model.id }
    end

    context 'name' do
      let(:field) { :name }
      it { expect(DbEntries::TouchRelated).to have_received(:perform_async).with model.id }
    end

    context 'other fields' do
      let(:field) { :updated_at }
      it { expect(DbEntries::TouchRelated).to_not have_received :perform_async }
    end
  end
end
