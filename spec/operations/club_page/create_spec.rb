# frozen_string_literal: true

describe ClubPage::Create do
  subject(:club_page) { ClubPage::Create.call params, user }

  let(:club) { create :club, owner: user, locale: locale }
  let(:user) { create :user }
  let(:locale) { :en }

  context 'valid params' do
    let(:params) do
      {
        club_id: club.id,
        parent_page_id: nil,
        name: 'test',
        text: 'zxc',
        layout: 'menu'
      }
    end

    it do
      expect(club_page).to be_persisted
      expect(club_page).to have_attributes params

      expect(club_page.topic).to be_persisted
    end
  end

  context 'invalid params' do
    let(:params) do
      {
        club_id: nil,
        parent_page_id: nil,
        name: 'test',
        text: 'zxc',
        layout: 'menu'
      }
    end
    it do
      expect(club_page).to be_new_record
      expect(club_page.errors).to have(1).item
      expect(club_page.topic).to be_nil
    end
  end
end
