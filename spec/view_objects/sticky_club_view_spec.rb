# frozen_string_literal: true

describe StickyClubView do
  describe 'sample sticky topic' do
    let(:sticky_topic) { StickyClubView.faq }
    it do
      expect(sticky_topic).to have_attributes(
        object: faq_club,
        title: faq_club.name,
        description: I18n.t('sticky_club_view.faq.description')
      )
    end
  end
end
