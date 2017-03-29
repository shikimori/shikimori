@p = (number) ->
  n = parseInt(number, 10)
  nplurals = 3
  plural = if n % 10 == 1 and n % 100 != 11 then 0 else if n % 10 >= 2 and n % 10 <= 4 and (n % 100 < 10 or n % 100 >= 20) then 1 else 2
  plural = if n == 0 then 0 else plural
  arguments[plural + 1]

@t = (phrase, options) ->
  console?.warn 'This method is deprecated. Use I18n.t instead'
  I18n.t phrase, options

@build_worker = (func) ->
  code = func.toString()
  code = code.substring(code.indexOf('{') + 1, code.lastIndexOf('}'))
  blob = new Blob([ code ], type: 'application/javascript')
  worker = new Worker(URL.createObjectURL(blob))
