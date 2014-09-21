class PersonComment < CharacterComment
  # текст топика
  def text
    "Обсуждение [#{self.linked_type.downcase}=#{self.linked_id}]человека[/#{self.linked_type.downcase}]."
  end
end
