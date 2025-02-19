# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

SimpleCov.formatter = if Gem.win_platform?
                        SimpleCov::Formatter::MultiFormatter[
                          SimpleCov::Formatter::HTMLFormatter
                        ]
                      else
                        SimpleCov::Formatter::MultiFormatter.new(
                          SimpleCov::Formatter::HTMLFormatter
                        )
                      end

SimpleCov.start do
  add_filter '/test/'
  add_filter '/features/'
  minimum_coverage 90
end
