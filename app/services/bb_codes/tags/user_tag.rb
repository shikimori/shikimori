class BbCodes::Tags::UserTag < BbCodes::Tags::CommentTag
  klass User
  user_field :itself
  includes_scope false
  is_bubbled false

  # def bbcode_regexp
  #   @bbcode_regexp ||= /
  #     \[#{name_regexp}=(?<id>\d+)\]
  #     # empty groups
  #     (?<text>)
  #     (?<quote>)
  #   /mix
  # end

  def entry_url entry
    UrlGenerator.instance.profile_url entry
  end

  def entry_id_url _entry_id
  end

  def build_attrs id:, type:, user_id:, text: # rubocop:disable UnusedMethodArgument
    {
      id: id,
      type: type,
      text: text
    }.compact
  end
end
