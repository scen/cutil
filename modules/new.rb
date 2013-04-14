require_relative 'notify'

TEMPLATE_FILE = {'cpp' => 'templates/cpp.cpp'}

def create_file(name, input, output, lang)
  if !TEMPLATE_FILE.include?(lang)
    notify_error("language not supported")
    return
  end

  template_arr = IO.read(TEMPLATE_FILE[lang]).split(/\r?\n/)

  File.open(name, 'w') do |file|
    template_arr.each do |line|
      if line.strip.start_with?('freopen')
        if line.strip.include?('.in')
          next if input.nil?
          line.sub!('template.in', input)
        else
          next if output.nil?
          line.sub!('template.out', output)
        end
      end
      file.write(line + "\n")
    end
  end
end