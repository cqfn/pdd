# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

module PDD
  module Rule
    # Rule for max duplicates.
    class MaxDuplicates
      # Ctor.
      # +xml+:: XML with puzzles
      def initialize(xml, max)
        @xml = xml
        @max = max.to_i
      end

      def errors
        @xml
          .xpath('//puzzle')
          .group_by { |p| p.xpath('body/text()').to_s }
          .map do |_, puzzles|
            next nil if puzzles.count <= @max

            "there are #{puzzles.count} duplicate(s) of the same puzzle: " +
              puzzles.map do |p|
                "#{p.xpath('file/text()')}:#{p.xpath('lines/text()')}"
              end.join(', ') +
              ", while maximum #{@max} duplicate is allowed"
          end.compact
      end
    end
  end
end
