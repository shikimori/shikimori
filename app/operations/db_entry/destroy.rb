class DbEntry::Destroy
  method_object :entry

  def call
    @entry.destroy!
  end
end
