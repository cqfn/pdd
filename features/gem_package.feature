Feature: Gem Package
  As a source code writer I want to be able to
  package the Gem into .gem file

  Scenario: Gem can be packaged
    Given It is Unix
    Given I have a "execs.rb" file with content:
    """
    #!/usr/bin/env ruby
    require 'rubygems'
    spec = Gem::Specification::load('./spec.rb')
    fail 'no executables' if spec.executables.empty?
    """
    When I run bash with
    """
    cd pdd
    gem build pdd.gemspec
    gem specification --ruby pdd-*.gem > ../spec.rb
    cd ..
    ruby execs.rb
    """
    Then Exit code is zero
