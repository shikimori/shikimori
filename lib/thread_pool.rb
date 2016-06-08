module Enumerable
  def parallel(options={}, &block)
    ThreadPool.new(self, options, &block)
  end
end

class ThreadPool
  @@defaults = {
    threads: 10,
    timeout: nil,
    timeout_message: "timeout\n",
    saver: nil,
    saver_interval: 60,
    log: false,
    debug_log: false,
    debugger: false
  }

  def self.defaults
    @@defaults
  end

  def self.defaults=(options)
    @@defaults = @@defaults.merge(options)
  end

  # конструктор
  def initialize(collection, options={}, &block)
    @threads = {}
    @finished = false
    @exception = nil
    @mutex = Mutex.new
    @queue = Queue.new
    @collection = collection
    @options = {}.merge!(@@defaults).merge!(options)

    return if !@collection || (@collection.respond_to?(:empty?) && @collection.empty?)
    @collection.each {|v| @queue << v }

    saver if @options[:saver]

    workers = 0
    [@options[:threads], @queue.size].min.times do
      workers += 1
      @mutex.synchronize do
        @threads[Thread.new(workers) { |worker_num| worker(worker_num, false, &block) }] = Time.now
      end
    end

    begin
      while !@finished && !@exception
        1.upto(10) do
          if @threads.empty?
            @finished = true
            break
          end
          sleep(1)
        end
        # при включенном таймауте, смотрим, какие из потоков выполняются слишком долго, и убираем их из пула, сами потоки при этом не убиваем
        if @options[:timeout]
          now = Time.now
          @threads.select {|k,v| now > v + @options[:timeout].seconds }.each do |k,v|
            print "worker %s timeout\n" % k[:worker_num] if @options[:log]
            k[:had_to_stop] = true
            @threads.delete(k)
            workers += 1
            @mutex.synchronize do
              @threads[Thread.new(workers) { |worker_num| worker(worker_num, false, &block) }] = Time.now
            end
          end

        end
        sleep(1)
      end
    rescue Exception => e
      @exception = e
    end

    # если случился экепшен, надо дождаться, пока потоки завершатся, или убить их
    if @exception
      debugger if @options[:debugger]
      @threads.each {|k,v| k[:had_to_stop] = true }
      print "%s\n%s\n" % [@exception.message, @exception.backtrace.join("\n")]
      print "waiting for all workers to stop...\n"# if @options[:log]
      begin
        @threads.map {|k,v| k }.each {|v| v.join }
      rescue
        kill_all_threads
      end
    end
    @finished = true

    # надо дождаться, пока доработает поток-сохраняльщик
    @saver.join if @options[:saver] && @saver
    # если был эксепшен, надо прокинуть его дальше
    raise @exception if @exception
  end

  private
  # поток-рабочий берёт из очереди данные и выполняет переданный блок к ним
  def worker(worker_num, suspended, &block)
    # id воркера
    Thread.current[:worker_num] = worker_num

    # пора ли умирать?
    Thread.current[:had_to_stop] = false

    # пора ли заснуть
    Thread.current[:had_to_suspend] = suspended

    # заснул ли поток
    Thread.current[:suspended] = false

    print "worker thread %d started, total workers: %d\n" % [worker_num, @threads.size] if @options[:log]
    #print "before loop before suspend_if_required %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
    ThreadPool.suspend_if_required
    #print "before loop after suspend_if_required %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
    object = nil
    while !@queue.empty? && !Thread.current[:had_to_stop] && !@finished && !@exception
      #print "before yield before suspend_if_required %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
      # если потоку сказано остановиться, то засыпаем, пока не скажут обратного
      ThreadPool.suspend_if_required
      #print "before yield before mutex %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
      @mutex.synchronize do
        break if @queue.empty?
        object = @queue.pop
        print "worker %d iteration for object: %s, total workers: %d, queue size: %d\n" % [worker_num, object, @threads.size, @queue.size] if @options[:log]
      end
      #print "before yield after mutex %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]

      next if object.nil?
      begin
        #print "before yield %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
        yield object
        #print "after yield %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
      rescue Exception => e
        print "unhandled exception %s in worker %d for object: %s\n" % [e.class, worker_num, object.to_yaml] if @options[:log]
        #print "%s\n%s\n" % [e.message, e.backtrace.join("\n")]
        @exception = e
        #print "after yield with exteption %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
      end

      #print "after yield before mutex %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
      @mutex.synchronize { @threads[Thread.current] = Time.now }
      #print "after yield after mutex %d, total workers: %d\n" % [worker_num, @threads.size] if @options[:debug_log]
    end
    @mutex.synchronize { @threads.delete(Thread.current) }
    print "worker thread %d finished, workers left: %d\n" % [worker_num, @threads.size] if @options[:log]
  end

  # приостановка выполнения потока, если это необходимо
  def self.suspend_if_required
    return unless Thread.current[:had_to_suspend]

    Thread.current[:suspended] = true
    #print "worker %d suspended\n" % [worker_num] if @options[:log]
    begin
      sleep(1)
    end while Thread.current[:suspended] && !Thread.current[:had_to_stop]
    #print "worker %d unsuspended\n" % [worker_num] if @options[:log]
  end

  # поток-сохраняльщик, выполняющий сохраняющую функцию через интервалы времени
  def saver
    @saver = Thread.new do
      begin
        print "saver thread started\n" if @options[:log]
        while !@finished && !@exception
          1.upto(@options[:saver_interval]) do
            break if @finished || @exception
            sleep(1)
          end
          print "preparing to call saver, telling workers to suspend...\n" if @options[:log]

          # говорим всем потокам, что надо завершить дела
          @threads.each {|k,v| k[:had_to_suspend] = true }
          # ждем пока все потоки остановятся
          while !@threads.all? {|k,v| k[:suspended] }
            print "%d workers are still alive...\n" % @threads.select {|k,v| !k[:suspended] }.size if @options[:log]
            sleep(1)
          end
          print "all workers suspended\n" if @options[:log]
          # и только после этого сохраняем
          @options[:saver].call
          # и затем говорим потокам продолжить работу, не забывая обновить таймер
          @threads.each do |k,v|
            k[:had_to_suspend] = false
            k[:suspended] = false
            @threads[k] = Time.now
          end

          kill_all_threads if @exception && @exception.class == Interrupt
          break if @finished || @exception
        end
        print "saver thread finished\n" if @options[:log]
        @saver = nil
      rescue Exception => e
        print "exception happened in saver: %s\n%s\n" % [e.message, e.backtrace.join("\n")]
        raise e
      end
    end
  end

  # принудительное завершение всех потоков. kill может привести к segmentation fault
  def kill_all_threads
    print "killing all workers\n"# if @options[:log]
    @threads.map {|k,v| k }.each {|v| v.kill }
  end
end
