# frozen_string_literal: true

require 'base64'
require 'digest'

# this class will perform selected hashing algorithm with random salt.
class RandomHash
  # Initialize function.
  #
  # @param [Symbol] algorithm Hash algorithm that be selected (default: SHA1).
  def initialize(algorithm: :SHA1)
    @provided_algo = algorithm
  end

  # This function will get the random seed in /dev/random.
  #
  # @param [Integer] byte Number of byte get from /dev/random (default: 1024 = 1KB).
  # @param [Integer] discard_first_byte Number of first byte in /dev/random that be discarded (default: 0).
  # @return [String] Random value from system random device that size is byte provided.
  def random_salt(byte: 1024, discard_first_byte: 0)
    # open system random seed
    random_device = File.new('/dev/random', 'r')

    # discard first byte by reading it
    random_device.read(discard_first_byte)
    salt = random_device.read(byte)

    random_device.close

    # return it
    salt
  end

  # This function will get the hash value from provided algorithm.
  #
  # @param [String] text Content that will be hashed.
  # @return [String] hexdigest after hashed.
  def hexdigest(text, salt_size: 1024, discard_salt_size: 0)
    # get the salt
    salt = random_salt byte: salt_size, discard_first_byte: discard_salt_size

    Digest(@provided_algo).hexdigest text + salt
  end

  # set it protected
  protected :random_salt
end
