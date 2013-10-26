class JobWithRestart
  def perform
    self.send(:do)

    GC.start
  end
end
