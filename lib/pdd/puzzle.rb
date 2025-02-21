# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

module PDD
  # Puzzle.
  class Puzzle
    # Ctor.
    # +props+:: Properties
    def initialize(props)
      @props = props
    end
    attr_reader :props
  end
end
