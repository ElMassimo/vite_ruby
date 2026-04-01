# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RAKE_BIN_ENGINE = File.expand_path("../bin/rake", __dir__)

ENGINE_SSR_ENTRYPOINT = <<~SSR
  import http from 'http'

  const server = http.createServer((req, res) => {
    res.writeHead(200)
    res.end('Hello, World!!!')
  })

  server.listen(8080)
SSR

RSpec.describe "Engine rake tasks" do
  before do
    remove_vite_files
  end

  after do
    remove_vite_files
  end

  it "tasks_mounted" do
    output = within_mounted_app { `#{RAKE_BIN_ENGINE} -T` }
    expect(output).to include("app:vite")
  end

  it "rake_tasks" do
    within_mounted_app { `#{RAKE_BIN_ENGINE} app:vite:binstubs` }

    expect(vite_binstub_path).to exist

    within_mounted_app_root { `bin/vite install` }

    expect(vite_config_ts_path).to exist
    expect(procfile_dev).to exist
    expect(app_frontend_dir).to exist

    within_mounted_app { `#{RAKE_BIN_ENGINE} app:vite:build` }

    expect(app_public_dir).to exist
    expect(app_public_dir.join(".vite/manifest.json")).to exist
    expect(app_public_dir.join("assets")).to exist
    expect(app_ssr_dir).not_to exist

    app_frontend_dir.join("ssr").mkdir
    app_frontend_dir.join("ssr/ssr.js").write(ENGINE_SSR_ENTRYPOINT)

    within_mounted_app { `#{RAKE_BIN_ENGINE} app:vite:build_all` }

    expect(app_ssr_dir.join("ssr.js")).to exist
    expect(app_ssr_dir.join(".vite/manifest.json")).not_to exist
    expect(app_ssr_dir.join(".vite/manifest-assets.json")).not_to exist

    within_mounted_app { `#{RAKE_BIN_ENGINE} app:vite:clobber` }

    expect(app_public_dir).not_to exist
  end

  it "cli" do
    within_mounted_app_root { `bundle exec vite install` }

    expect(vite_binstub_path).to exist
    expect(vite_config_ts_path).to exist
    expect(procfile_dev).to exist
    expect(app_frontend_dir).to exist

    within_mounted_app_root { `bin/vite build --mode development` }

    expect(app_public_dir).to exist
    expect(app_public_dir.join(".vite/manifest.json")).to exist
    expect(app_public_dir.join("assets")).to exist

    within_mounted_app_root {
      expect(`bin/vite version`).to include(ViteRails::VERSION)
    }
  end

  it "cli_commands" do
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
        expect(ViteRuby::CLI::Build.new.call(mode: ViteRuby.mode)).to be_truthy
      }
      stub_runner("build", "--ssr") {
        expect(ViteRuby::CLI::Build.new.call(mode: ViteRuby.mode, ssr: true)).to be_truthy
      }

      FileUtils.mkdir_p(app_ssr_dir.to_s)
      ssr_path = app_ssr_dir.join("ssr.js")
      ssr_path.write("")
      stub_kernel_exec("node", ssr_path.to_s) {
        ViteRuby::CLI::SSR.new.call(mode: ViteRuby.mode)
      }

      stub_runner("--wat", exec: true) {
        expect(ViteRuby::CLI::Dev.new.call(mode: ViteRuby.mode, args: ["--wat"])).to be_truthy
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

  def stub_runner(*args, **opts)
    status = MockProcessStatus.new
    # build_with_vite receives the extra args (everything after "build")
    # Use block-scoped define_method to avoid stubs leaking across multiple stub_runner calls.
    # Capture invocation args and assert after yield to avoid self-context issues inside define_method.
    if args.first == "build"
      extra_args = args[1..]
      captured = nil
      original = ViteRuby::Builder.instance_method(:build_with_vite)
      ViteRuby::Builder.define_method(:build_with_vite) do |*actual_args|
        captured = actual_args
        ["stdout", "", status]
      end
      begin
        yield
      ensure
        ViteRuby::Builder.define_method(:build_with_vite, original)
      end
      expect(captured).to eq(extra_args)
    else
      expected = [args, opts].flatten.reject(&:blank?)
      captured = nil
      original = ViteRuby.instance_method(:run)
      ViteRuby.define_method(:run) do |argv, **options|
        captured = [argv] + [options]
        ["stdout", "", status]
      end
      begin
        yield
      ensure
        ViteRuby.define_method(:run, original)
      end
      actual = captured.flatten.reject(&:blank?)
      expect(actual).to eq(expected)
    end
  end

  def stub_kernel_exec(*command)
    expect(Kernel).to receive(:exec).with(*command)
    yield
  end

  def mounted_app_path
    Pathname.new(File.expand_path("../test", __dir__)).join("mounted_app")
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
    root_dir.join("app/views/layouts/application.html.erb").write(
      Pathname.new(path_to_test_app).join("app/views/layouts/application.html.erb").read,
    )
    gitignore_path.write("")
    @command_results = []
  end
end
