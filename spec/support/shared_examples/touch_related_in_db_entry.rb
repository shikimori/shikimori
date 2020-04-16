shared_examples :touch_related_in_db_entry do |db_entry|
  describe '#touch_related' do
    let(:model) { create db_entry }
    before do
      allow(Animes::TouchRelated).to receive :perform_in
    end
    subject! do
      db_entry.to_s.capitalize.constantize
        .find(model.id)
        .update(field => 'test 123456')
    end

    context 'russian' do
      let(:field) { :russian }
      it do
        expect(Animes::TouchRelated)
          .to have_received(:perform_in)
          .with 3.seconds, model.id, model.class.base_class.name
      end
    end

    context 'name' do
      let(:field) { :name }
      it do
        expect(Animes::TouchRelated)
          .to have_received(:perform_in)
          .with 3.seconds, model.id, model.class.base_class.name
      end
    end

    context 'other fields' do
      let(:field) { :updated_at }
      it { expect(Animes::TouchRelated).to_not have_received :perform_in }
    end
  end
end
