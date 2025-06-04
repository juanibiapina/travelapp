# -*- encoding: utf-8 -*-
# stub: logfmt 0.0.10 ruby lib

Gem::Specification.new do |s|
  s.name = "logfmt".freeze
  s.version = "0.0.10".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/cyberdelia/logfmt-ruby/issues", "changelog_uri" => "https://github.com/cyberdelia/logfmt-ruby/blog/master/CHANGELOG.md", "documentation_uri" => "https://github.com/cyberdelia/logfmt-ruby", "source_code_uri" => "https://github.com/cyberdelia/logfmt-ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Timoth\u00E9e Peignier".freeze]
  s.date = "2022-04-30"
  s.description = "Parse log lines in the logfmt style.".freeze
  s.email = ["timothee.peignier@tryphon.org".freeze]
  s.homepage = "https://github.com/cyberdelia/logfmt-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Parse logfmt messages.".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<pry-byebug>.freeze, ["~> 3.9".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0".freeze])
end
