class Summary < ApplicationRecord
  include AntispamConcern
  include Moderatable
  include Viewable

  belongs_to :user
  belongs_to :anime, optional: true
  belongs_to :manga, optional: true

  validates :body, presence: true
  # validates :anime, presence: true, if: -> { manga_id.nil? }
  # validates :manga, presence: true, if: -> { anime_id.nil? }

  def html_body
    BbCodes::Text.call body
  end
end
