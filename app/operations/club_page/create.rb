# frozen_string_literal: true

class ClubPage::Create < ServiceObjectBase
  pattr_initialize :params, :user

  def call
    ClubPage.create @params
  end
end
