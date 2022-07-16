# frozen_string_literal: true

class ClubPage::Create < ServiceObjectBase
  pattr_initialize :params

  def call
    ClubPage.create @params
  end
end
