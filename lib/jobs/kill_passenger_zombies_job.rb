class KillPassengerZombiesJob
  MemoryLimit = 3.5
  SleepInterval = 5

  def running?(pid)
    begin
      return Process.getpgid(pid) != -1
    rescue Errno::ESRCH
      return false
   end
  end

  def perform
    workers = %x{ps aux}.split("\n").select { |v| v =~ /Rack/ }.map do |v|
      data = v.strip.split(/ +/)
      ap data
      {
        pid: data[1].to_i,
        mem: data[3].to_f,
        time: data[9].to_i
      }
    end

    workers.each do |worker|
      if worker[:time] > 50
        puts "#{Time.now}: Killing #{worker[:pid]}, processor time == #{worker[:time]}%"
        Process.kill("KILL", worker[:pid])
        next
      end

      next if worker[:mem] < MemoryLimit

      puts "#{Time.now}: Killing #{worker[:pid]}, memory usage == #{worker[:mem]}%"
      Process.kill("SIGUSR1", worker[:pid])

      puts "Finished kill attempt. Sleeping for #{SleepInterval} seconds to give it time to die..."
      sleep SleepInterval

      if running?(worker[:pid])
        puts "Process is still running - die bitch"
        Process.kill("KILL", worker[:pid])
      end
    end
  end
end
