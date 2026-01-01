# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

module PDD
  module Rule
    module Text
      # Rule for minimum length of description.
      class MinWords
        # Ctor.
        # +xml+:: XML with puzzles
        def initialize(xml, min)
          @xml = xml
          @min = min.to_i
        end

        def errors
          @xml.xpath('//puzzle').map do |p|
            words = p.xpath('body/text()').to_s.split.size
            next nil if words >= @min

            "Puzzle #{p.xpath('file/text()')}:#{p.xpath('lines/text()')} " \
              "has a very short description of just #{words} words while " \
              "a minimum of #{@min} is required"
          end.compact
        end
      end
    end
  end
end
