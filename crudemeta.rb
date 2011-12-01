#!/usr/bin/env ruby

# Copyright (C) 2011 Felix Rabe

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


class Matcher
  attr_reader :regexp, :block

  def initialize regexp, &block
    @regexp = regexp
    @block = block
  end
  
  def try text
    return nil unless match = @regexp.match(text)
    puts "/\\A#{@regexp}/ === #{text.inspect}" if $DEBUG
    @block[match]
    return match
  end
end

class Parser
  def initialize
    @text = ""
    @matchers = [
      matcher(/(?m)\A./) { |m| },  # fallback for unrecognized text
      matcher(/\A\/([^\/]*)\/\s*(.*)$/) { |m|  # /REGEXP/ RUBY_CODE
        pattern, statement = m[1..2]
        @matchers << matcher(Regexp.new '\A' + pattern) { |m|
          eval statement
        }
      }
    ]
  end

  def matcher regexp, &block
    Matcher.new regexp, &block
  end

  def parse text
    @text << text
    while match = find_match
      @text = match.post_match
    end
    self
  end
  
  def find_match
    @matchers.reverse_each.find { |m| break m if m = m.try(@text) }
  end
end

if __FILE__ == $0
  p = Parser.new
  p.parse $_ while gets
end
