class Comments::ForbidTagChange
  method_object %i[model! field! tag_regexp! tag_error_label!]

  def call
    from_value = @model.changes_to_save[field].first || ''
    to_value = @model.changes_to_save[field].last || ''

    if from_value.scan(@tag_regexp) == to_value.scan(@tag_regexp)
      true
    else
      add_error
      false
    end
  end

private

  def add_error
    @model.errors[field] << I18n.t(
      'activerecord.errors.models.base.forbidden_tag_change',
      tag_error_label: @tag_error_label
    )
  end
end
