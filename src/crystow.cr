require "file_utils"
require "option_parser"

alias LinkInfo = {original: String, dest: String}

def get_linkable_files(app_path : String, dest : String = Path.home.to_s) : Array(LinkInfo)
  app_path = Path[app_path].expand(home: true).to_s
  puts "Expanded app_path: #{app_path}"
  raise ArgumentError.new("App path #{app_path} doesn't exist.") unless Dir.exists?(app_path)

  linkables = [] of LinkInfo
  puts "Searching for files in: #{app_path}"
  glob_pattern = File.join(app_path, "**", "*")
  puts "Glob pattern: #{glob_pattern}"
  Dir.glob(glob_pattern).each do |filepath|
    puts "Found file: #{filepath}"
    if File.directory?(filepath)
      puts "Skipping directory: #{filepath}"
      next
    end
    linkpath = filepath.gsub(app_path, dest)
    puts "Adding linkable: #{filepath} -> #{linkpath}"
    linkables << {original: filepath, dest: linkpath}
  end
  puts "Found #{linkables.size} linkable files"
  linkables
end

def stow(linkables : Array(LinkInfo), simulate : Bool, verbose : Bool, force : Bool)
  puts "Stow function called with: simulate=#{simulate}, verbose=#{verbose}, force=#{force}" # Debug output
  linkables.each do |linkinfo|
    filepath, linkpath = linkinfo[:original], linkinfo[:dest]
    puts "Will link #{filepath} -> #{linkpath}" if verbose

    unless simulate
      Dir.mkdir_p(File.dirname(linkpath))
      puts "Created directory: #{File.dirname(linkpath)}"
      if !File.exists?(linkpath)
        File.symlink(filepath, linkpath)
        puts "Created symlink: #{filepath} -> #{linkpath}"
      else
        if force
          File.delete(linkpath)
          File.symlink(filepath, linkpath)
          puts "Forced symlink creation: #{filepath} -> #{linkpath}" # Debug output
        else
          puts "Skipping linking #{filepath} -> #{linkpath}" if verbose
        end
      end
    end
  end
end

def write_version
  puts "Crystow version 0.1.0"
end

def crystow(version : Bool, simulate : Bool, verbose : Bool, force : Bool,
            app : String, dest : String)
  puts "Crystow function called with: version=#{version}, simulate=#{simulate}, verbose=#{verbose}, force=#{force}, app=#{app}, dest=#{dest}" # Debug output
  if version
    write_version
    exit
  end

  begin
    stow(get_linkable_files(app_path: app, dest: dest), simulate: simulate, verbose: verbose, force: force)
  rescue ex : ArgumentError
    puts "Error happened: #{ex.message}"
  end
end

def main
  version = false
  simulate = false # Changed default to false
  verbose = false
  force = false
  app = ""
  dest = Path.home.to_s

  OptionParser.parse do |parser|
    parser.banner = "CryStow 0.1.0 (Manage your dotfiles easily)"

    parser.on("-v", "--version", "Show version") { version = true }
    parser.on("-s", "--simulate", "Simulate without making changes") { simulate = true }
    parser.on("--verbose", "Show verbose output") { verbose = true }
    parser.on("-f", "--force", "Force overwrite existing files") { force = true }
    parser.on("-a APP", "--app=APP", "Specify the app path") { |a| app = a }
    parser.on("-d DEST", "--dest=DEST", "Specify the destination path") { |d| dest = d }
    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end

    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  puts "After parsing: version=#{version}, simulate=#{simulate}, verbose=#{verbose}, force=#{force}, app=#{app}, dest=#{dest}" # Debug output

  if version
    write_version
    exit
  end

  if app.empty?
    puts "ERROR: No app specified."
    exit(1)
  end

  begin
    crystow(version: version, simulate: simulate, verbose: verbose, force: force, app: app, dest: dest)
  rescue ex
    puts "An error occurred: #{ex.message}"
    puts ex.backtrace.join("\n")
  end
end

main
