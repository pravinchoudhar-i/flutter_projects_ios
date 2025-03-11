# Pod helper script for Flutter iOS integration.

require 'fileutils'
require 'json'

def parse_KV_file(file, separator='=')
  file_abs_path = File.expand_path(file)
  if !File.exists? file_abs_path
    return [];
  end
  generated_key_values = {}
  skip_lines_starting_with = ["#", "/"]

  File.foreach(file_abs_path) do |line|
    next if skip_lines_starting_with.any? { |pattern| line =~ /^\s*#{pattern}/ }
    plugin = line.split(pattern=separator)
    if plugin.length == 2
      key = plugin[0].strip()
      value = plugin[1].strip()
      generated_key_values[key] = value
    else
      puts "Invalid plugin specification: #{line}"
    end
  end
  generated_key_values
end

def flutter_root
  generated_xcode_build_settings = parse_KV_file(File.join(__dir__, 'flutter_export_environment.rb'))
  if generated_xcode_build_settings.empty?
    return File.expand_path(File.join('..', '..'))
  end

  generated_xcode_build_settings['FLUTTER_ROOT']
end

def flutter_ios_engine_path
  File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine', 'ios')
end

def install_flutter_engine_pod
  engine_dir = flutter_ios_engine_path
  if !File.exist?(engine_dir)
    # Run 'flutter precache' to fetch the artifacts.
    raise "#{engine_dir} does not exist. Run 'flutter precache' to fetch the artifacts."
  end
  pod 'Flutter', :path => engine_dir
end

def install_flutter_plugin_pods(app_dir)
  plugin_pods = parse_KV_file(File.join(app_dir, '.flutter-plugins'))
  plugin_pods.each do |name, path|
    if (name && path)
      pod name, :path => File.expand_path(path)
    end
  end
end

def flutter_install_all_ios_pods(app_dir)
  install_flutter_engine_pod
  install_flutter_plugin_pods(app_dir)
end
