# frozen_string_literal: true

require "git/lint/rake/register"
require "rubocop/rake_task"

Git::Lint::Rake::Register.call
RuboCop::RakeTask.new

desc "Run code quality checks"
task quality: %i[git_lint rubocop]

task default: :quality
