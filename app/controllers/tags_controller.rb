class TagsController < ShikimoriController
  #autocomplete :tag, :name, :full => true, :order => 'name'

  ## получение элементов для автодополнения
  #def get_autocomplete_items(parameters)
    #model = parameters[:model]
    #method = parameters[:method]
    #options = parameters[:options]
    #term = parameters[:term]
    #is_full_search = options[:full]

    #items = Tag.where(:name => term).
                      #order(options[:order]).
                      #all

    #if items.size < 10
      #items += Tag.where(
                         #{:name.like => term.downcase.gsub(/([A-zА-я0-9])/, '\1% ').sub(/ $/, '')} |
                         #{:name.like => "%#{term.downcase.gsub(' ', '% ')}%"} |
                         #{:name.like => "%#{term.downcase.broken_translit.gsub(' ', '% ')}%"}
                        #).
                        #where(:id.not_in => items.size > 0 ? items.map {|v| v.id } : [0]).
                        #limit(10-items.size).
                        #order(options[:order]).
                        #all
    #end
    #items = items.reverse
  #end

  ## возвращение даннух запросу на автодополнение
  #def json_for_autocomplete(items, method, extra)
    #items.collect {|item| {"data" => item.id,
                           #"value" => item.name,
                           #"label" => render_to_string(:partial => 'tags/suggest.html.erb', :layout => false, :locals => { :tag => item })
                          #}}
  #end
end
