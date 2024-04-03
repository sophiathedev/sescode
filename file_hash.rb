# frozen_string_literal: true

require_relative './random_hash'

# This class will process for hashing and securing the source code.
class FileHash
  # Initialize function.
  #
  # @param [Symbol] language Language provided for process (default: cpp).
  def initialize(language: :cpp, algorithm: :SHA2)
    @process_language = language
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

    LanguageExt.hash_process(@source_content, @output_file, @hash_algo)
    @output_file.close
  end
end
