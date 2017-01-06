class AddSourceBbcodeToDescriptionFields < ActiveRecord::Migration
  def change
    update_descriptions Anime
    update_descriptions Manga
    update_descriptions Character
  end

  private

  def update_descriptions klass
    count = klass.count
    puts "updating #{count} #{klass.name}"
    index = 0

    klass.find_each do |model|
      index += 1
      puts "#{index} / #{count}"

      model.description_ru = new_description_ru(model)
      model.description_en = new_description_en(model)
      model.save!
    end
  end

  def new_description_ru model
    return model.description_ru if model.description_ru =~ /\[source\]/
    "#{model.description_ru}[source]#{model.source}[/source]"
  end

  def new_description_en model
    value = model.description_en
    type = model.class.name.downcase
    Mal::ProcessDescription.(value, type, model.id)
  end
end
