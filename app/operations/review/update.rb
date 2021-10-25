class Review::Update
  method_object %i[review! params! faye!]

  def call
    @faye.update @review, fixed_params
  end

private

  def fixed_params
    if @review.db_entry_released_before?
      params
    else
      params.except(:is_written_before_release)
    end
  end
end
