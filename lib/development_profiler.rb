#class DevelopmentProfiler
  #def self.prof file_name
    #RubyProf.start
    #yield_result = yield
    #results = RubyProf.stop

    ##printer = RubyProf::FlatPrinter.new(results)
    ##printer.print(STDOUT)

    ## Print a flat profile to text
    #File.open "/tmp/#{file_name}-graph.html", 'w' do |file|
      #RubyProf::GraphHtmlPrinter.new(results).print(file)
    #end

    #File.open "/tmp/#{file_name}-flat.txt", 'w' do |file|
      ## RubyProf::FlatPrinter.new(results).print(file)
      #RubyProf::FlatPrinterWithLineNumbers.new(results).print(file)
    #end

    #File.open "/tmp/#{file_name}-stack.html", 'w' do |file|
      #RubyProf::CallStackPrinter.new(results).print(file)
    #end

    #File.open "/tmp/#{file_name}-flame", 'w' do |file|
      #RubyProf::FlameGraphPrinter.new(results).print(file)
    #end

    #File.open "/tmp/#{file_name}-flame.svg", 'w' do |file|
      #file.write %x{cat /tmp/#{file_name}-flame | /Users/morr/Develop/FlameGraph/flamegraph.pl --countname=ms --width=1350}
    #end

    #yield_result
  #end
#end
