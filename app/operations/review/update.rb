class Review::Update
  method_object :review, :params

  def call
    @review.update fixed_params
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
