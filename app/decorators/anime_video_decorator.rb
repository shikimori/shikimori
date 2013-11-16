class AnimeVideoDecorator < Draper::Decorator
  delegate_all

  def description
    if object.description_html.blank?
      format_html_text object.description_mal
    else
      object.description_html
    end
  end

  def comments
    @comments ||= [1,2,3]
  end
end
