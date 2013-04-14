require 'commander/import'
require_relative 'new'
require_relative 'notify'
require_relative 'cl'

program :name, "cutil"
program :version, "0.1"
program :description, "contest helper utility (c) Stanley Cen 2013"

# create a new source file
command :new do |c|
  c.description = 'creates a source file'
  c.syntax = 'cutil new [options...] [file_name]'
  c.option '-i STRING', String, 'input file (default: stdin)'
  c.option '-o STRING', String, 'output file (default: stdout)'
  c.option '-l STRING', String, 'language (default: cpp)'
  c.when_called do |args, options|
    options.default :l => 'cpp'
    if args.empty?
      notify_error("file name missing")
    else
      create_file(args.first, options.i, options.o, options.l.downcase)
    end
  end
end

# compile a source file
command :cl do |c|
  c.description = 'compiles a source file'
  c.option '-m', 'compile with MSVC instead of g++'
  c.option '-d', 'compile in debug mode'
  c.option '-n', 'compile without optimization'
  c.when_called do |args, options|
    if args.empty?
      notify_error("file name missing")
    else
      compile_file(args.first, options.d, options.n, options.m)
    end
  end
end