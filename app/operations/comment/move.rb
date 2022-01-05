class Comment::Move
  method_object %i[comment! commentable! from_reply to_reply]

  QUOTE_REPLACEMENT_TEMPLATES = [
    [
      '\[quote=(?:%<from_short_key>s)%<basis_prefix_option>s%<from_id>s(?<suffix>;|\\])',
      '[quote=%<to_short_key>s%<to_id>i%<suffix>s'
    ],
    [
      '\[(?:%<from_key>s)=%<basis_prefix_option>s%<from_id>s(?<suffix>;|\\])',
      '[%<to_key>s=%<to_id>i%<suffix>s'
    ],
    [
      '(?<=^| )>\?%<from_short_key>s%<from_id>s(?<suffix>;)',
      '>?%<to_short_key>s%<to_id>i%<suffix>s'
    ]
  ]

  def call
    change_replies if @from_reply && @to_reply
    change_commentable

    @comment.save
  end

private

  def change_replies #  rubocop:disable MethodLength
    from_key = key @from_reply

    QUOTE_REPLACEMENT_TEMPLATES.each do |(regexp_template, replacement_template)|
      formatted_template = format regexp_template,
        from_id: @from_reply.id,
        from_key: from_key,
        from_short_key: short_key(from_key),
        basis_prefix_option: basis_prefix_option(from_key)
      regexp = Regexp.new formatted_template # , Regexp::EXTENDED

      @comment.body = @comment.body.gsub(regexp) do
        to_key = key @to_reply

        format replacement_template,
          to_id: @to_reply.id,
          to_key: to_key,
          to_short_key: short_key(to_key),
          suffix: $LAST_MATCH_INFO[:suffix]
      end
    end
  end

  def change_commentable
    @comment.assign_attributes(
      commentable_id: @commentable.id,
      commentable_type: @commentable.class.base_class.name
    )
  end

  def key model
    model.class.base_class.name.downcase
  end

  def short_key key
    key[0]
  end

  def basis_prefix_option key
    key == 'comment' ? '?' : ''
  end
end
