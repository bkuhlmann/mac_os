# frozen_string_literal: true

require "git/lint/rake/register"
require "rubocop/rake_task"

Git::Lint::Rake::Register.call
RuboCop::RakeTask.new

task default: %i[git_lint rubocop]
