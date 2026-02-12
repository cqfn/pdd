# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'qbash'
require_relative 'test__helper'
require_relative '../lib/pdd'

# Test pdd as shell executable bin.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestBin < Minitest::Test
  def test_prints_help
    stdout = qbash('pdd --help', chdir: File.join(__dir__, '../bin'))
    assert_includes(stdout, 'Usage')
  end
end
