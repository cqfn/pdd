# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

module PDD
  module Rule
    module Roles
      # Rule for available roles checking.
      class Available
        # Ctor.
        # +xml+:: XML with puzzles
        def initialize(xml, roles)
          @xml = xml
          @roles = roles.split(',')
        end

        def errors
          @xml.xpath('//puzzle').map do |p|
            role = p.xpath('role/text()').to_s
            next nil if @roles.include?(role)

            "puzzle #{p.xpath('file/text()')}:#{p.xpath('lines/text()')}" +
              if role.empty?
                " doesn't define any role" \
                  ", while one of these roles is required: #{@roles}"
              else
                " defines role #{role}" \
                  ", while only these roles are allowed: #{@roles}"
              end
          end.compact
        end
      end
    end
  end
end
