class PollVariant < ApplicationRecord
  acts_as_votable

  belongs_to :poll, touch: true

  validates :label, presence: true

  def label_html
    BbCodes::Text
      .call(label)
      .gsub(
        /<a class="b-link" href="(.*?)"( rel=".*?")?>/,
        '<a class="b-link" href="\\1" target="_blank"\\2>'
      )
  end
end
