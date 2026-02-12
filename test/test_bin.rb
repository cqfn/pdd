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

  def test_removes_puzzle
    Dir.mktmpdir do |tmp|
      file = File.join(tmp, 'a.txt')
      File.write(file, "hello!\n\x40todo #55 haha \n\nbye!")
      stdout = qbash(
        "pdd --source #{Shellwords.escape(tmp)} --remove --verbose --file /dev/null",
        chdir: File.join(__dir__, '../bin')
      )
      assert_includes(stdout, 'removed')
      assert_includes(File.read(file), 'hello')
      assert_includes(File.read(file), 'bye!')
      refute_includes(File.read(file), 'haha')
    end
  end
end
