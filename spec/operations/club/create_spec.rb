# frozen_string_literal: true

describe Club::Create do
  subject(:club) { Club::Create.call params }

  before { allow_any_instance_of(Club).to receive :add_to_index }

  context 'valid params' do
    let(:params) { { name: 'Test Club', owner_id: user.id } }
    it do
      expect(club).to be_persisted
      expect(club).to_not be_changed
      expect(club.errors).to be_empty

      expect(club.topic).to be_present
    end
  end

  context 'invalid params' do
    let(:params) { { owner_id: user.id } }
    it do
      expect(club).to be_new_record
      expect(club.errors).to have(1).item
      expect(club.topic).to_not be_present
    end
  end
end
