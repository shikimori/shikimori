# frozen_string_literal: true

describe ClubPage::Create do
  subject(:club_page) { ClubPage::Create.call params, user }

  let(:club) { create :club, owner: user, locale: locale, is_censored: is_censored }
  let(:is_censored) { [true, false].sample }
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
      expect(club_page.all_topics).to be_empty
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
      expect(club_page.errors).to be_present
    end
  end
end
