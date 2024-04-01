# frozen_string_literal: true

require_relative './random_hash'

# This class will process for hashing and securing the source code.
class FileHash
  # Initialize function.
  #
  # @param [Symbol] language Language provided for process (default: cpp).
  def initialize(language: :cpp, algorithm: :SHA2, verbose: false)
    @process_language = language
    @verbosity_level = verbose
    @hash_algo = algorithm

    require_relative "./ext/#{@process_language.to_s}"
  end

  # This function will load the source code file.
  #
  # @param [String] source_path Path to source code file.
  # @param [String] output_path Path for output after hashing the source code.
  def do(source_path, output_path)
    @source_path = source_path
    @output_path = output_path
    @source_content = File.read(source_path, encoding: 'utf-8')
    @output_file = File.open(output_path, 'w', encoding: 'utf-8')

    hash_process_cpp
    @output_file.close
  end

  # Function process hashing for C++ source code
  def hash_process_cpp
    # init the lexer
    lexer = Lexer.new
    # init RandomHash device with SHA-2
    verbose "Initialize random device with #{@hash_algo} algorithm."
    random_device = RandomHash.new(algorithm: @hash_algo)

    # Get the list tokens lexed from lexer
    verbose "Perform lexical in file: #{@source_path}."
    tokens = lexer.lex @source_content

    # Tokens have two type IDENTIFIER and PREPROCESSOR
    # IDENTIFIER is the name of variable, keyword and function name
    # PREPROCESSOR is the #include, #define, #pragma ...
    # Split keyword into two list
    identifier_list = Array.new
    preprocessor_list = Array.new
    verbose "Found tokens:"
    tokens.each do |token|
      verbose "    #{token.name}\t#{token.value.squeeze(' ')}", banner: false
      # Use include? function for sure that all identifder is difference
      if (token.name == :IDENTIFIER or token.name == :STRING or token.name == :CHAR) and !identifier_list.include? token.value
        identifier_list << token.value
      elsif token.name == :PREPROCESSOR
        preprocessor_list << token.value.squeeze(' ')
      end
    end

    # When changing names and keywords with their hash values, there are variables with one-letter names that can be substituted with other hash values so we sort these names by length and alphabet.
    identifier_list.sort_by! { |t| [t.length, t] }.reverse!

    # The source code will have some user definition macros so we temporary remove the user preprocessor
    @source_content.gsub! /\#.*/, ''
    @source_content.gsub! /\n+/, ''

    # Store the hashed name into a hash
    identifier_hash = Hash.new
    verbose "Perform hashing:"
    identifier_list.each do |_id|
      identifier_hash[_id] = random_device.hexdigest(_id)
      verbose "    #{_id} [#{identifier_hash[_id]}]", banner: false

      # replace it when source code have only that body code (without preprocessor and definition)
      @source_content.gsub! /\b#{Regexp.escape(_id)}\b/, "_#{identifier_hash[_id]}"
    end

    # Process write into file
    # Write the preprocessor first
    verbose "Writing preprocessor."
    preprocessor_list.each do |pre|
      @output_file << pre << "\n"
    end
    # Insert the define that hashed name
    verbose "Writing hashing definition."
    identifier_hash.each do |_id, h|
      @output_file << '#define ' << "_#{h} #{_id}\n"
    end
    # Write the source code
    verbose "Writing main source code."
    @output_file << @source_content
    verbose "Done."
  end

  def verbose(*text, banner: true, newline: true)
    if @verbosity_level
      print "[sescode] " if banner
      print text.join(' ')
      puts if newline
    end
  end

  private :hash_process_cpp, :verbose
end
