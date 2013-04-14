require 'open3'
require 'timeout'
require 'stringio'
require 'sys/proctable'

require_relative 'notify'

class ExecRet
  attr_accessor :timed_out, :timed_elapsed, :max_mem_usage, :ret_code, :inst

  def initialize(args = {})
    args.each do |x, y|
      send "#{x}=", y
    end
  end
end

class MonitorExec
  attr_accessor :stdin, :stdout, :stderr, :pid, :ctx, :timeout, :cmd, :exit_status
  attr_accessor :stdout_txt, :stderr_txt, :proc_thr

  TIMED_OUT = -1

  def initialize(cmd, timeout)
    @timeout = timeout
    @cmd = cmd
  end

  def run()
    start_time = Time.now
    end_time = start_time

    @ctx = Thread.new {
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        stdin.close
        @proc_thr = wait_thr
        @pid = wait_thr.pid
        @stdout_txt, @stderr_txt = [stdout, stderr].map { |p|
          begin
            p.read
          ensure
            p.close
          end
        }
        @exit_status = wait_thr.value
      end
    }

    timed_out = false
    peak_virtual_size = -1
    ret_code = -1

    loop do
      cur_time = Time.now

      if !@proc_thr.nil? && !@proc_thr.alive?
        end_time = cur_time
        @proc_thr.kill unless @proc_thr.nil?
        @ctx.kill unless @proc_thr.nil?
        ret_code = @exit_status.exitstatus
        break
      elsif !@proc_thr.nil? && @proc_thr.alive?
        proc_info = Sys::ProcTable.ps(@pid)
        peak_virtual_size = [peak_virtual_size, proc_info.peak_virtual_size].max unless proc_info.nil?
      end

      if @timeout != -1 && cur_time - start_time > @timeout
        timed_out = true
        Process.kill(9, @pid)
        @proc_thr.exit unless @proc_thr.nil?
        @ctx.exit unless @proc_thr.nil?
        break
      end

      sleep 0.001
    end

    return (ExecRet.new timed_out: timed_out, timed_elapsed: (timed_out ? @timeout : (end_time - start_time)), 
                        max_mem_usage: (peak_virtual_size / (1024.0 * 1024.0)), ret_code: ret_code, inst: self)
  end
end
