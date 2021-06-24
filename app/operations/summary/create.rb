class Summary::Create
  method_object :params

  def call
    Summary.create @params
  end
end
