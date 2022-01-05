class Comment::Move
  method_object %i[comment! to! basis]

  QUOTE_REPLACEMENT_TEMPLATES = [
    [
      '\[quote=(?:%<basis_short_key>s)%<basis_prefix_option>s%<basis_id>s(?<suffix>;|\\])',
      '[quote=%<to_short_key>s%<to_id>i%<suffix>s'
    ],
    [
      '\[(?:%<basis_key>s)=%<basis_prefix_option>s%<basis_id>s(?<suffix>;|\\])',
      '[%<to_key>s=%<to_id>i%<suffix>s'
    ],
    [
      '(?<=^| )>\?%<basis_short_key>s%<basis_id>s(?<suffix>;)',
      '>?%<to_short_key>s%<to_id>i%<suffix>s'
    ]
  ]

  def call
    change_replies if @basis
    change_commentable

    @comment.save
  end

private

  def change_replies #  rubocop:disable MethodLength
    basis_key = key basis

    QUOTE_REPLACEMENT_TEMPLATES.each do |(regexp_template, replacement_template)|
      formatted_template = format regexp_template,
        basis_id: @basis.id,
        basis_key: basis_key,
        basis_short_key: short_key(basis_key),
        basis_prefix_option: basis_prefix_option(basis_key)
      regexp = Regexp.new formatted_template # , Regexp::EXTENDED

      @comment.body = @comment.body.gsub(regexp) do
        to_key = key @to

        format replacement_template,
          to_key: to_key,
          to_short_key: short_key(to_key),
          to_id: @to.id,
          suffix: $LAST_MATCH_INFO[:suffix]
      end
    end
  end

  def change_commentable
    @comment.assign_attributes(
      commentable_id: @to.id,
      commentable_type: @to.class.base_class.name
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
