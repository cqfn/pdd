# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

module PDD
  module Rule
    module Estimate
      # Rule for min estimate.
      class Min
        # Ctor.
        # +xml+:: XML with puzzles
        def initialize(xml, min)
          @xml = xml
          @min = min.to_i
        end

        def errors
          @xml.xpath("//puzzle[number(estimate) < #{@min}]").map do |p|
            "Puzzle #{p.xpath('file/text()')}:#{p.xpath('lines/text()')} " \
              "has an estimate of #{p.xpath('estimate/text()')} minutes, " \
              "which is lower than #{@min} minutes"
          end
        end
      end

      # Rule for max estimate.
      class Max
        # Ctor.
        # +xml+:: XML with puzzles
        def initialize(xml, min)
          @xml = xml
          @min = min.to_i
        end

        def errors
          @xml.xpath("//puzzle[number(estimate) > #{@min}]").map do |p|
            "Puzzle #{p.xpath('file/text()')}:#{p.xpath('lines/text()')} " \
              "has an estimate of #{p.xpath('estimate/text()')} minutes, " \
              "which is bigger than #{@min} minutes"
          end
        end
      end
    end
  end
end
