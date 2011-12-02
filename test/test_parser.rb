#!/usr/bin/env ruby

$:.unshift File.expand_path("../../", __FILE__)
require "test/unit"
require "crudemeta"

class ParserForTest < Parser
  attr_reader :matches

  def initialize
    @matches = []
    super
  end

  def find_match
    match = super
    @matches << match[0] if match
    match
  end
end

class TestParser < Test::Unit::TestCase
  def setup
    @parser = ParserForTest.new
  end
  
  def parse s
    @parser.parse(s)
  end
  
  def test_empty_does_nothing
    assert_equal [], parse("").matches
  end
  
  def test_ignore_unrecognized_characters
    assert_equal %w(w o r d), parse("word").matches
  end
  
  def test_global_vars_are_cool
    code = '
      /// $x = 0
      /\n/ $x += 1
    
    '
    parse(code)
    assert_equal 2, $x
  end
  
  def test_matching_object_is_accessible_through_m
    code = '
      /// $matches = []
      /\d+/ $matches << "%#{m[0]}"
      /\w+/ $matches << m[0]
      "50 times I walked that 1 path!" she said.
    '
    parse(code)
    assert_equal %w(%51 times I walked that %1 path she said), $matches
  end
end
