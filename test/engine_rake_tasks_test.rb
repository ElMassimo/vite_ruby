# frozen_string_literal: true

require "test_helper"
require "fileutils"

SSR_ENTRYPOINT = <<~SSR
  import http from 'http'

  const server = http.createServer((req, res) => {
    res.writeHead(200)
    res.end('Hello, World!!!')
  })

  server.listen(8080)
SSR

describe "EngineRakeTasks" do
  def mounted_app_path
    Pathname.new(File.expand_path(__dir__)).join("mounted_app")
  end

  def root_dir
    mounted_app_path.join("test/dummy")
  end

  def gitignore_path = root_dir.join(".gitignore")

  def vite_binstub_path = root_dir.join("bin/vite")

  def vite_config_ts_path = root_dir.join("vite.config.ts")

  def procfile_dev = root_dir.join("Procfile.dev")

  def app_frontend_dir = root_dir.join("app/frontend")

  def app_public_dir = root_dir.join("public/vite-dev")

  def app_ssr_dir = root_dir.join("public/vite-ssr")

  def tmp_dir = root_dir.join("tmp")

  def within_mounted_app(&block)
    Dir.chdir(mounted_app_path, &block)
  end

  def within_mounted_app_root(&block)
    Dir.chdir(mounted_app_path.join("test/dummy"), &block)
  end

  def stub_runner(*args, **opts)
    status = MockProcessStatus.new
    expected = [args, opts].flatten.reject(&:blank?)
    captured = nil
    original = ViteRuby.instance_method(:run)
    ViteRuby.define_method(:run) { |*argv, **options|
      captured = [argv, options].flatten.reject(&:blank?)
 ["stdout", "", status]
    }
    begin
      yield
    ensure
      ViteRuby.define_method(:run, original)
    end
    expect(captured) == expected
  end

  def stub_kernel_exec(*command)
    captured = nil
    Kernel.stub(:exec, ->(*args) { captured = args }) { yield }
    expect(captured) == command
  end

  def remove_vite_files
    [vite_binstub_path, vite_config_ts_path, procfile_dev].each do |file|
      file.delete if file.exist?
    end
    [app_frontend_dir, app_public_dir, app_ssr_dir, tmp_dir].each do |dir|
      dir.rmtree if dir.exist?
    end
    root_dir.join("app/views/layouts/application.html.erb").write(
      Pathname.new(path_to_test_app).join("app/views/layouts/application.html.erb").read,
    )
    gitignore_path.write("")
  end

  def setup
    super
    remove_vite_files
  end

  def teardown
    remove_vite_files
    super
  end

  test "lists vite tasks when mounted" do
    output = within_mounted_app { `"#{RAKE_BIN}" -T` }

    expect(output).to_include("app:vite")
  end

  test "runs rake tasks" do
    within_mounted_app { `"#{RAKE_BIN}" app:vite:binstubs` }

    expect(vite_binstub_path).to_be(:exist?)

    within_mounted_app_root { `bin/vite install` }

    expect(vite_config_ts_path).to_be(:exist?)
    expect(procfile_dev).to_be(:exist?)
    expect(app_frontend_dir).to_be(:exist?)

    within_mounted_app { `"#{RAKE_BIN}" app:vite:build` }

    expect(app_public_dir).to_be(:exist?)
    expect(app_public_dir.join(".vite/manifest.json")).to_be(:exist?)
    expect(app_public_dir.join("assets")).to_be(:exist?)
    expect(app_ssr_dir).not_to_be(:exist?)

    app_frontend_dir.join("ssr").mkdir
    app_frontend_dir.join("ssr/ssr.js").write(SSR_ENTRYPOINT)

    within_mounted_app { `"#{RAKE_BIN}" app:vite:build_all` }

    expect(app_ssr_dir.join("ssr.js")).to_be(:exist?)
    expect(app_ssr_dir.join(".vite/manifest.json")).not_to_be(:exist?)
    expect(app_ssr_dir.join(".vite/manifest-assets.json")).not_to_be(:exist?)

    within_mounted_app { `"#{RAKE_BIN}" app:vite:clobber` }

    expect(app_public_dir).not_to_be(:exist?)
  end

  test "runs CLI commands" do
    within_mounted_app_root { `bundle exec vite install` }

    expect(vite_binstub_path).to_be(:exist?)
    expect(vite_config_ts_path).to_be(:exist?)
    expect(procfile_dev).to_be(:exist?)
    expect(app_frontend_dir).to_be(:exist?)

    within_mounted_app_root { `bin/vite build --mode development` }

    expect(app_public_dir).to_be(:exist?)
    expect(app_public_dir.join(".vite/manifest.json")).to_be(:exist?)
    expect(app_public_dir.join("assets")).to_be(:exist?)

    version_output = within_mounted_app_root { `bin/vite version` }
    expect(version_output).to_include(ViteRails::VERSION)
  end

  test "runs CLI command objects" do
    within_mounted_app_root do
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
        assert(ViteRuby::CLI::Build.new.call(mode: ViteRuby.mode))
      }
      stub_runner("build", "--ssr") {
        assert(ViteRuby::CLI::Build.new.call(mode: ViteRuby.mode, ssr: true))
      }

      FileUtils.mkdir_p(app_ssr_dir.to_s)
      ssr_path = app_ssr_dir.join("ssr.js")
      ssr_path.write("")
stub_kernel_exec("node", ssr_path.to_s) {
        ViteRuby::CLI::SSR.new.call(mode: ViteRuby.mode)
}

      stub_runner("--wat", exec: true) {
        assert(ViteRuby::CLI::Dev.new.call(mode: ViteRuby.mode, args: ["--wat"]))
      }

      ViteRuby::CLI::Clobber.new.call(mode: ViteRuby.mode)
    end
  ensure
    ENV.delete("VITE_RUBY_ROOT")
    refresh_config
  end
end
