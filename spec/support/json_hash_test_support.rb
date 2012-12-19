# Several workarounds to get our test setup working in multiple ruby environments credit is 
# attributed to all the projects that found solutions to these test headaches! 


module SparkApiTest
# directly taken from Rails 3.1's OrderedHash
# see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/ordered_hash.rb

# The order of iteration over hashes in Ruby 1.8 is undefined. For example, you do not know the
# order in which +keys+ will return keys, or +each+ yield pairs. <tt>ActiveSupport::OrderedHash</tt>
# implements a hash that preserves insertion order, as in Ruby 1.9:
#
#   oh = ActiveSupport::OrderedHash.new
#   oh[:a] = 1
#   oh[:b] = 2
#   oh.keys # => [:a, :b], this order is guaranteed
#
# <tt>ActiveSupport::OrderedHash</tt> is namespaced to prevent conflicts with other implementations.
class OrderedHash < ::Hash #:nodoc:
  def to_yaml_type
    "!tag:yaml.org,2002:omap"
  end

  def encode_with(coder)
    coder.represent_seq '!omap', map { |k,v| { k => v } }
  end

  def to_yaml(opts = {})
    if YAML.const_defined?(:ENGINE) && !YAML::ENGINE.syck?
      return super
    end

    YAML.quick_emit(self, opts) do |out|
      out.seq(taguri) do |seq|
        each do |k, v|
          seq.add(k => v)
        end
      end
    end
  end

  def nested_under_indifferent_access
    self
  end

  # Hash is ordered in Ruby 1.9!
  if RUBY_VERSION < '1.9'

    # In MRI the Hash class is core and written in C. In particular, methods are
    # programmed with explicit C function calls and polymorphism is not honored.
    #
    # For example, []= is crucial in this implementation to maintain the @keys
    # array but hash.c invokes rb_hash_aset() originally. This prevents method
    # reuse through inheritance and forces us to reimplement stuff.
    #
    # For instance, we cannot use the inherited #merge! because albeit the algorithm
    # itself would work, our []= is not being called at all by the C code.

    def initialize(*args, &block)
      super
      @keys = []
    end

    def self.[](*args)
      ordered_hash = new

      if (args.length == 1 && args.first.is_a?(Array))
        args.first.each do |key_value_pair|
          next unless (key_value_pair.is_a?(Array))
          ordered_hash[key_value_pair[0]] = key_value_pair[1]
        end

        return ordered_hash
      end

      unless (args.size % 2 == 0)
        raise ArgumentError.new("odd number of arguments for Hash")
      end

      args.each_with_index do |val, ind|
        next if (ind % 2 != 0)
        ordered_hash[val] = args[ind + 1]
      end

      ordered_hash
    end

    def initialize_copy(other)
      super
      # make a deep copy of keys
      @keys = other.keys
    end

    def []=(key, value)
      @keys << key unless has_key?(key)
      super
    end

    def delete(key)
      if has_key? key
        index = @keys.index(key)
        @keys.delete_at index
      end
      super
    end

    def delete_if
      super
      sync_keys!
      self
    end

    def reject!
      super
      sync_keys!
      self
    end

    def reject(&block)
      dup.reject!(&block)
    end

    def keys
      @keys.dup
    end

    def values
      @keys.collect { |key| self[key] }
    end

    def to_hash
      self
    end

    def to_a
      @keys.map { |key| [ key, self[key] ] }
    end

    def each_key
      return to_enum(:each_key) unless block_given?
      @keys.each { |key| yield key }
      self
    end

    def each_value
      return to_enum(:each_value) unless block_given?
      @keys.each { |key| yield self[key]}
      self
    end

    def each
      return to_enum(:each) unless block_given?
      @keys.each {|key| yield [key, self[key]]}
      self
    end

    alias_method :each_pair, :each

    alias_method :select, :find_all

    def clear
      super
      @keys.clear
      self
    end

    def shift
      k = @keys.first
      v = delete(k)
      [k, v]
    end

    def merge!(other_hash)
      if block_given?
        other_hash.each { |k, v| self[k] = key?(k) ? yield(k, self[k], v) : v }
      else
        other_hash.each { |k, v| self[k] = v }
      end
      self
    end

    alias_method :update, :merge!

    def merge(other_hash, &block)
      dup.merge!(other_hash, &block)
    end

    # When replacing with another hash, the initial order of our keys must come from the other hash -ordered or not.
    def replace(other)
      super
      @keys = other.keys
      self
    end

    def invert
      OrderedHash[self.to_a.map!{|key_value_pair| key_value_pair.reverse}]
    end

    private
      def sync_keys!
        @keys.delete_if {|k| !has_key?(k)}
      end
  end
end
end

# Originally based on a fix found in Koala, a facebook client gem that has compatibile licensing.
# See: https://raw.github.com/arsduo/koala/master/spec/support/json_testing_fix.rb
#
# when testing across Ruby versions, we found that JSON string creation inconsistently ordered keys
# which is a problem because our mock testing service ultimately matches strings to see if requests are mocked
# this fix solves that problem by ensuring all hashes are created with a consistent key order every time
module MultiJson

  class << self
    def dump_with_ordering(object)
      # if it's a hash, recreate it with k/v pairs inserted in sorted-by-key order
      # (for some reason, REE fails if we don't assign the ternary result as a local variable
      # separately from calling encode_original)
      dump_original(sort_object(object))
    end

    alias_method :dump_original, :dump
    alias_method :dump, :dump_with_ordering
  
    def load_with_ordering(string)
      sort_object(load_original(string))
    end

    alias_method :load_original, :load
    alias_method :load, :load_with_ordering
    
    private 
  
    def sort_object(object)
      if object.is_a?(Hash)
        sort_hash(object)
      elsif object.is_a?(Array)
        object.collect {|item| item.is_a?(Hash) ? sort_hash(item) : item}
      else
        object
      end
    end
  
    def sort_hash(unsorted_hash)
      sorted_hash = SparkApiTest::OrderedHash.new(sorted_hash)
      unsorted_hash.keys.sort {|a, b| a.to_s <=> b.to_s}.inject(sorted_hash) {|hash, k| hash[k] = unsorted_hash[k]; hash}
    end
  end
end

