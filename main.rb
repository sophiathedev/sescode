# frozen_string_literal: true

require 'optparse'
require_relative './file_hash'

options = { verbose: false, target_lang: :cpp, salt_size: 1024, discard_size: 0, algo: :SHA2 }
opts_parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby main.rb [options]"

  opts.on("-f FILEPATH", "--file FILEPATH", "Required file to process") do |filepath|
    options[:file] = filepath
  end
  opts.on("-o FILEPATH", "--output FILEPATH", "Output path") do |filepath|
    options[:output_file] = filepath
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |verbosity|
    options[:verbose] = verbosity
  end

  opts.on("-a ALGORITHM", "--algorithm ALGORITHM", "Hash algorithm used") do |algo|
    options[:algo] = algo.to_sym
  end
  opts.on("-l LANGUAGE", "--language LANGUAGE", "Language used in source code") do |d_language|
    options[:target_lang] = d_language.to_sym
  end

  opts.on("--random-size SIZE", "Salt seed size in bytes") do |size|
    options[:salt_size] = size
  end

  opts.on("--discard-size SIZE", "Discarded seed size when refreshing between the hash") do |size|
    options[:discard_size] = size
  end

  opts.on_tail("-h", "--help", "Display this help message") do |help_msg|
    puts opts
    exit
  end

  # opts.on("--version") do |version|
  #   puts File.read("VERSION")
  # end
end
opts_parser.parse!

if __FILE__ == $0
  unless options[:file] and options[:output_file]
    puts "error: A source code file required.\nUse -h for help message."
    exit
  end
  FileHash.new(language: options[:target_lang], algorithm: options[:algo], verbose: options[:verbose]).do(options[:file], options[:output_file])
end
