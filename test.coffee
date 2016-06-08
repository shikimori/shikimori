class Model extends EventBus # or some BaseModel class with EventBus
  on: (event, callback) -> # method from event bus patter
  trigger: (event) -> # method from event bus patter

class Form
  constructor: (model) ->
    @$('input').on 'change', ->
      model[@name] = @value
      model.trigger 'change' # или model.change()

class Preview
  constructor: (model) ->
    model.on 'change', @render

  render: ->
    # render template
    # JST[template_path](model)


model = new Model
form = new Form model
preview = new Preview model
