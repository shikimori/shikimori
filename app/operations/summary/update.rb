class Summary::Update
  method_object :summary, :params

  def call
    @summary.update fixed_params
  end

private

  def fixed_params
    if @summary.db_entry_released_before?
      params
    else
      params.except(:is_written_before_release)
    end
  end
end
