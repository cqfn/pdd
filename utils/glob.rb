# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

# Utility glob class
class Glob
  NO_LEADING_DOT = '(?=[^\.])'.freeze

  def initialize(glob_string)
    @glob_string = glob_string
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def to_regexp
    chars = @glob_string.gsub(%r{(\*\*/\*)|(\*\*)}, '*').chars
    in_curlies = 0, escaping = false
    chars.map do |char|
      if escaping
        escaping = false
        return char
      end
      case char
      when '*'
        '.*'
      when '?'
        '.'
      when '.'
        '\\.'
      when '{'
        in_curlies += 1
        '('
      when '}'
        if in_curlies.positive?
          in_curlies -= 1
          return ')'
        end
        return char
      when ','
        in_curlies.positive? ? '|' : char
      when '\\'
        escaping = true
        '\\'
      else
        char
      end
    end.join
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
