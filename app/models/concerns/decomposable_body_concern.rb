module DecomposableBodyConcern
  extend ActiveSupport::Concern

  def body= value
    @decomposed_body = nil
    super value
  end

  def decomposed_body
    @decomposed_body ||= Topics::DecomposedBody.from_value body
  end
end
