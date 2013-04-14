require_relative 'notify'
require_relative 'exec'
require_relative 'util'

def compile_file(name, debug, no_opt, use_msvc)
  if !File.exist?(name)
    notify_error("file does not exist")
    return
  end

  out_file = name.chomp(File.extname(name))
  out_file += ".exe" if is_windows?

  # fix the error output messages
  ENV["LC_ALL"] = "C"

  if use_msvc
    options = []
    options <<= "/Zi" if debug
    options <<= "/O2" unless no_opt
    cmd = "cl #{options.join ' '} #{name}"

    puts "Compiling with: #{cmd}"

    exec_ret = MonitorExec.new(cmd, 10).run

    puts exec_ret.inst.stdout_txt unless exec_ret.inst.stdout_txt.empty?

    if exec_ret.ret_code != 0
      puts ""
      notify_error("compilation failed!")
    else
      puts "\ncompilation succeeded!"
    end
  else
    options = ["-lm", "-o", out_file]
    options <<= "-O2" unless no_opt
    options <<= ["-g", "-DDEBUG"] if debug
    cmd = "g++-4 #{options.join ' '} #{name}"

    puts "Compiling with: #{cmd}"

    exec_ret = MonitorExec.new(cmd, 10).run

    puts exec_ret.inst.stderr_txt unless exec_ret.inst.stderr_txt.empty?

    if exec_ret.ret_code != 0
      puts ""
      notify_error("compilation failed!")
    else
      puts "\ncompilation succeeded!"
    end
  end
end