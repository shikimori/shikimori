class Summary < ApplicationRecord
  belongs_to :user
  belongs_to :anime, optional: true
  belongs_to :manga, optional: true

  def html_body
    BbCodes::Text.call body
  end
end
