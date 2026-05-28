# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

module PDD
  # Utility glob class
  class Glob
    NO_LEADING_DOT = '(?=[^\.])'.freeze

    def initialize(string)
      @string = string
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def to_regexp
      chars = @string.gsub(%r{(\*\*/\*)|(\*\*)}, '*').chars
      curlies = 0, escaping = false
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
          curlies += 1
          '('
        when '}'
          if curlies.positive?
            curlies -= 1
            return ')'
          end
          return char
        when ','
          curlies.positive? ? '|' : char
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
end
