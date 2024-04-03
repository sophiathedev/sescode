# frozen_string_literal: true

require 'lex'
require 'digest'

require_relative '../random_hash'

module LanguageExt
  # simple lex for regex the identifier and preprocessor
  class Lexer < Lex::Lexer
    tokens(
      :IDENTIFIER, :PREPROCESSOR, :STRING, :CHAR, :NUMBER
    )

    rule :newline, /\n+/ do |lexer, token|
      lexer.advance_line token.value.length
    end

    # ignore comment and preprocessor
    rule :PREPROCESSOR, /\#.*/
    rule :STRING, /\".*\"/
    rule :CHAR, /\'.*\'/

    rule :NUMBER, /\d+/ do |lexer, token|
      token
    end
    rule :IDENTIFIER, /[_\$a-zA-Z][_\$0-9a-zA-Z]*/

    ignore " \t"

    error do |lexer, token|
    end
  end

  # Function process hashing for C++ source code
  #
  # @param [String] source_content Source code content
  # @param [File] output_file File object for output
  # @param [Symbol] hash_algo Hash algorithm provided
  def self.hash_process(source_content, output_file, hash_algo)
    @source_content, @output_file, @hash_algo = source_content, output_file, hash_algo
    # init the lexer
    lexer = Lexer.new
    # init RandomHash device with SHA-2
    random_device = RandomHash.new(algorithm: @hash_algo)

    # Get the list tokens lexed from lexer
    
    tokens = lexer.lex @source_content

    # Tokens have two type IDENTIFIER and PREPROCESSOR
    # IDENTIFIER is the name of variable, keyword and function name
    # PREPROCESSOR is the #include, #define, #pragma ...
    # Split keyword into two list
    identifier_list = Array.new
    preprocessor_list = Array.new
    
    tokens.each do |token|
      # Use include? function for sure that all identifder is difference
      if (token.name == :IDENTIFIER or token.name == :STRING or token.name == :CHAR) and !identifier_list.include? token.value
        identifier_list << token.value
      elsif token.name == :PREPROCESSOR
        preprocessor_list << token.value.squeeze(' ')
      elsif token.name == :NUMBER
        @source_content.gsub! /\b#{Regexp.escape(token.value)}\b/, "0x#{token.value.to_i.to_s(16)}"
      end
    end

    # When changing names and keywords with their hash values, there are variables with one-letter names that can be substituted with other hash values so we sort these names by length and alphabet.
    identifier_list.sort_by! { |t| [t.length, t] }.reverse!

    # The source code will have some user definition macros so we temporary remove the user preprocessor
    @source_content.gsub! /\#.*\n+/, ''

    # Store the hashed name into a hash
    identifier_hash = Hash.new
    
    identifier_list.each do |_id|
      identifier_hash[_id] = random_device.hexdigest(_id)

      # replace it when source code have only that body code (without preprocessor and definition)
      @source_content.gsub! /\b#{Regexp.escape(_id)}\b/, "_#{identifier_hash[_id]}"
    end
    # Process write into file
    # Write the preprocessor first
    preprocessor_list.each do |pre|
      @output_file << pre << "\n"
    end
    # Insert the define that hashed name
    identifier_hash.each do |_id, h|
      @output_file << '#define ' << "_#{h} #{_id}\n"
    end
    # Write the source code
    @output_file << @source_content
  end
end