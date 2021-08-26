defmodule GitHooks.ConfigTest do
  @moduledoc false

  use ExUnit.Case, async: false
  use GitHooks.TestSupport.ConfigCase

  alias GitHooks.Config

  describe "Given a git hook type" do
    test "when it is all then all the configured hooks are run" do
      put_git_hook_config([:pre_commit, :pre_push], tasks: ["help", "help deps"])

      assert Config.tasks(:all) == {:all, ["help", "help deps", "help", "help deps"]}
    end

    test "when there are not configured mix tasks then an empty list is returned" do
      put_git_hook_config(:pre_commit, tasks: ["help", "help deps"])

      assert Config.tasks(:unknown_hook) == {:unknown_hook, []}
    end

    test "when there are configured mix tasks then a list of the mix tasks is returned" do
      tasks = ["help", "help deps"]

      put_git_hook_config(:pre_commit, tasks: tasks)

      assert Config.tasks(:pre_commit) == {:pre_commit, tasks}
    end

    test "when current branch is allowed to run for the git hook then current_branch_allowed? function returns true" do
      branches_config = [whitelist: ["master"], blacklist: []]

      put_git_hook_config(:pre_commit, branches: branches_config)

      assert Config.current_branch_allowed?(:pre_commit)
    end

    test "when branches config is not provided then current_branch_allowed? function return true" do
      assert Config.current_branch_allowed?(:pre_commit)
    end

    test "when current branch is disallowed to run git hook then current_branch_allowed? function returns false" do
      branches_config = [whitelist: [], blacklist: ["master"]]

      put_git_hook_config(:pre_commit, branches: branches_config)

      refute Config.current_branch_allowed?(:pre_commit)
    end

    test "when the verbose is enabled for the git hook then the verbose config function returns true" do
      put_git_hook_config(:pre_commit, verbose: true)

      assert Config.verbose?(:pre_commit) == true
    end

    test "when the verbose is enabled globally then the verbose config function returns true" do
      Application.put_env(:git_hooks, :verbose, true)

      assert Config.verbose?(:pre_commit) == true
    end

    test "when the verbose is true globally but false for a githook then the verbose config function returns false" do
      put_git_hook_config(:pre_commit, verbose: false)
      Application.put_env(:git_hooks, :verbose, true)

      assert Config.verbose?(:pre_commit) == false
    end

    test "when the git hook is unknown then the verbose config function returns false" do
      put_git_hook_config(:pre_commit, verbose: true)

      assert Config.verbose?(:unknown_hook) == false
    end

    test "when there are no supported git hooks configured then an empty list is returned" do
      assert Config.git_hooks() == []
    end

    test "when request the git hooks types then a list of supported git hooks types is returned" do
      put_git_hook_config([:pre_commit, :pre_push])

      assert Config.git_hooks() == [:pre_commit, :pre_push]
    end

    test "when the verbose is enabled then a IO stream is returned" do
      put_git_hook_config([:pre_commit], verbose: true)

      assert Config.io_stream(:pre_commit) == IO.stream(:stdio, :line)
    end

    test "when the verbose is disabled then an empty string is returned" do
      put_git_hook_config([:pre_commit, :pre_push], verbose: false)

      assert Config.io_stream(:pre_commit) == ""
    end
  end
end
