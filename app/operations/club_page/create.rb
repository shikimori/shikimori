# frozen_string_literal: true

class ClubPage::Create
  method_object :params

  def call
    ClubPage.create @params
  end
end
