# frozen_string_literal: true

class ClubPage::Create < ServiceObjectBase
  pattr_initialize :params, :user

  def call
    ClubPage.transaction do
      club_page = ClubPage.create @params

      generate_topic club_page if club_page.persisted?
      club_page
    end
  end

private

  def generate_topic club_page
    Topics::Generate::Topic.call(
      model: club_page,
      user: @user,
      locale: club_page.club.locale
    )
  end
end
