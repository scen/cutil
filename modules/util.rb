require 'rbconfig'

def is_windows?
  return (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
end