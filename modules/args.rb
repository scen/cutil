require 'commander/import'


program :name, "cutil"
program :version, "0.1"
program :description, "contest helper utility (c) Stanley Cen 2013"

command :cl do |c|
  c.description = 'compiles a source file'
  c.option '-d', '--debug', 'compile in debug mode'
  c.option '-s', '--symbols', 'compile with symbols'
  c.when_called do |args, options|
  end
end