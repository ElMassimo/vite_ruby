# frozen_string_literal: true

require "test_helper"
require "fileutils"

class EngineRakeTasksTest < ViteRuby::Test
  def setup
    super
    remove_vite_files
  end

  def teardown
    remove_vite_files
    super
  end

  def test_tasks_mounted
    output = within_mounted_app { `bundle exec rake -T` }

    assert_includes output, "app:vite"
  end

  def test_rake_tasks
    within_mounted_app { `bundle exec rake app:vite:binstubs` }

    assert_path_exists vite_binstub_path

    within_mounted_app_root { `bin/vite install` }

    assert_path_exists vite_config_ts_path
    assert_path_exists procfile_dev
    assert_path_exists app_frontend_dir

    within_mounted_app { `bundle exec rake app:vite:build` }

    assert_path_exists app_public_dir
    assert_path_exists app_public_dir.join(".vite/manifest.json")
    assert_path_exists app_public_dir.join("assets")
    refute_path_exists app_ssr_dir

    app_frontend_dir.join("ssr").mkdir
    app_frontend_dir.join("ssr/ssr.js").write(SSR_ENTRYPOINT)

    within_mounted_app { `bundle exec rake app:vite:build_all` }

    assert_path_exists app_ssr_dir.join("ssr.js")
    refute_path_exists app_ssr_dir.join(".vite/manifest.json")
    refute_path_exists app_ssr_dir.join(".vite/manifest-assets.json")

    within_mounted_app { `bundle exec rake app:vite:clobber` }

    refute_path_exists app_public_dir
  end

  def test_cli
    within_mounted_app_root { `bundle exec vite install` }

    assert_path_exists vite_binstub_path
    assert_path_exists vite_config_ts_path
    assert_path_exists procfile_dev
    assert_path_exists app_frontend_dir

    within_mounted_app_root { `bin/vite build --mode development` }

    assert_path_exists app_public_dir
    assert_path_exists app_public_dir.join(".vite/manifest.json")
    assert_path_exists app_public_dir.join("assets")

    within_mounted_app_root { assert_includes `bin/vite version`, ViteRails::VERSION }
  end

  def test_cli_commands
    within_mounted_app_root {
      ViteRuby.commands.verify_install

      ENV["VITE_RUBY_ROOT"] = Dir.pwd
      refresh_config

      ViteRuby::CLI::Install.new.call
      ViteRuby.commands.verify_install
      ViteRuby::CLI::Version.new.call
      stub_kernel_exec("bundle exec vite upgrade_packages") {
        ViteRuby::CLI::Upgrade.new.call
      }
      ViteRuby::CLI::UpgradePackages.new.call

      stub_runner("build") {
        assert ViteRuby::CLI::Build.new.call(mode: ViteRuby.mode)
      }
      stub_runner("build", "--ssr") {
        assert ViteRuby::CLI::Build.new.call(mode: ViteRuby.mode, ssr: true)
      }

      FileUtils.mkdir_p(app_ssr_dir.to_s)
      ssr_path = app_ssr_dir.join("ssr.js")
      ssr_path.write("")
      stub_kernel_exec("node", ssr_path.to_s) {
        ViteRuby::CLI::SSR.new.call(mode: ViteRuby.mode)
      }

      stub_runner("--wat", exec: true) {
        assert ViteRuby::CLI::Dev.new.call(mode: ViteRuby.mode, args: ["--wat"])
      }

      ViteRuby::CLI::Clobber.new.call(mode: ViteRuby.mode)
    }
  ensure
    ENV.delete("VITE_RUBY_ROOT")
    refresh_config
  end

private

  def within_mounted_app(&block)
    Dir.chdir(mounted_app_path, &block).tap { |result| @command_results << result }
  end

  def within_mounted_app_root(&block)
    Dir.chdir(mounted_app_path.join("test/dummy"), &block).tap { |result| @command_results << result }
  end

  def stub_runner(*args, **opts, &block)
    mock = Minitest::Mock.new
    status = MockProcessStatus.new

    mock.expect(:call, ["stdout", "stderr", status]) do |*argv, **options|
      assert_equal [args, opts].flatten.reject(&:blank?), (argv + [options]).flatten.reject(&:blank?)
    end
    ViteRuby.stub_any_instance(:run, ->(*stub_args, **stub_opts) { mock.call(*stub_args, **stub_opts) }, &block)
    mock.verify
  end

  def stub_kernel_exec(*command, &block)
    mock = Minitest::Mock.new
    mock.expect(:call, nil, command)
    Kernel.stub(:exec, mock, &block)
    mock.verify
  end

  def mounted_app_path
    Pathname.new(File.expand_path(__dir__)).join("mounted_app")
  end

  def root_dir
    mounted_app_path.join("test/dummy")
  end

  def gitignore_path
    root_dir.join(".gitignore")
  end

  def vite_binstub_path
    root_dir.join("bin/vite")
  end

  def vite_config_ts_path
    root_dir.join("vite.config.ts")
  end

  def procfile_dev
    root_dir.join("Procfile.dev")
  end

  def app_frontend_dir
    root_dir.join("app/frontend")
  end

  def app_public_dir
    root_dir.join("public/vite-dev")
  end

  def app_ssr_dir
    root_dir.join("public/vite-ssr")
  end

  def tmp_dir
    root_dir.join("tmp")
  end

  def remove_vite_files
    [vite_binstub_path, vite_config_ts_path, procfile_dev].each do |file|
      file.delete if file.exist?
    end
    [app_frontend_dir, app_public_dir, app_ssr_dir, tmp_dir].each do |dir|
      dir.rmtree if dir.exist?
    end
    root_dir.join("app/views/layouts/application.html.erb").write(Pathname.new(path_to_test_app).join("app/views/layouts/application.html.erb").read)
    gitignore_path.write("")
    @command_results = []
  end

  SSR_ENTRYPOINT = <<~SSR
    import http from 'http'

    const server = http.createServer((req, res) => {
      res.writeHead(200)
      res.end('Hello, World!!!')
    })

    server.listen(8080)
  SSR
end
