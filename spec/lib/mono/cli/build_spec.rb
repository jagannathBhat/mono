# frozen_string_literal: true

RSpec.describe Mono::Cli::Build do
  context "with Elixir project" do
    context "with single repo" do
      it "builds the project" do
        prepare_project :elixir_single
        output =
          capture_stdout do
            in_project { run_build }
          end

        expect(output).to include("Building package: elixir_single_project (.)")
        expect(performed_commands).to eql([
          ["/elixir_single_project", "mix compile"]
        ])
        expect(exit_status).to eql(0), output
      end
    end

    context "with mono repo" do
      it "builds the packages" do
        prepare_project :elixir_mono
        output =
          capture_stdout do
            in_project { run_build }
          end

        expect(output).to include("Building package: package_one (packages/package_one)")
        expect(output).to include("Building package: package_two (packages/package_two)")
        expect(performed_commands).to eql([
          ["/elixir_mono_project/packages/package_one", "mix compile"],
          ["/elixir_mono_project/packages/package_two", "mix compile"]
        ])
        expect(exit_status).to eql(0), output
      end
    end
  end

  context "with Ruby project" do
    context "with single repo" do
      it "builds the project" do
        prepare_project :ruby_single
        output =
          capture_stdout do
            in_project { run_build }
          end

        expect(output).to include("Building package: ruby_single_project (.)")
        expect(performed_commands).to eql([
          ["/ruby_single_project", "gem build"]
        ])
        expect(exit_status).to eql(0), output
      end
    end

    context "with mono repo" do
      it "builds the packages" do
        prepare_project :ruby_mono
        output =
          capture_stdout do
            in_project { run_build }
          end

        expect(output).to include("Building package: package_one (packages/package_one)")
        expect(output).to include("Building package: package_two (packages/package_two)")
        expect(performed_commands).to eql([
          ["/ruby_mono_project/packages/package_one", "gem build"],
          ["/ruby_mono_project/packages/package_two", "gem build"]
        ])
        expect(exit_status).to eql(0), output
      end
    end
  end

  context "with Node.js project" do
    context "with npm" do
      context "with npm < 7" do
        pending "install new npm version"
      end

      context "with npm >= 7" do
        context "with single repo" do
          it "builds the project" do
            prepare_project :nodejs_npm_single
            output =
              capture_stdout do
                in_project { run_build }
              end

            expect(output).to include("Building package: nodejs_npm_single_project (.)")
            expect(performed_commands).to eql([
              ["/nodejs_npm_single_project", "npm run build"]
            ])
            expect(exit_status).to eql(0), output
          end
        end

        context "with mono repo" do
          it "builds the project workspace" do
            prepare_project :nodejs_npm_mono
            output =
              capture_stdout do
                in_project { run_build }
              end

            expect(output).to include(
              "Building package: package_one (packages/package_one)",
              "Building package: package_two (packages/package_two)"
            )
            expect(performed_commands).to eql([
              ["/nodejs_npm_mono_project/packages/package_one", "npm run build"],
              ["/nodejs_npm_mono_project/packages/package_two", "npm run build"]
            ])
            expect(exit_status).to eql(0), output
          end
        end
      end
    end

    context "with yarn" do
      context "with yarn < 1" do
        pending "install new yarn version"
      end

      context "with yarn >= 1" do
        context "with single repo" do
          it "builds the project" do
            prepare_project :nodejs_yarn_single
            output =
              capture_stdout do
                in_project { run_build }
              end

            expect(output).to include("Building package: nodejs_yarn_single_project (.)")
            expect(performed_commands).to eql([
              ["/nodejs_yarn_single_project", "yarn run build"]
            ])
            expect(exit_status).to eql(0), output
          end
        end

        context "with mono repo" do
          it "builds the project workspace" do
            prepare_project :nodejs_yarn_mono
            output =
              capture_stdout do
                in_project { run_build }
              end

            expect(output).to include(
              "Building package: package_one (packages/package_one)",
              "Building package: package_two (packages/package_two)"
            )
            expect(performed_commands).to eql([
              ["/nodejs_yarn_mono_project/packages/package_one", "yarn run build"],
              ["/nodejs_yarn_mono_project/packages/package_two", "yarn run build"]
            ])
            expect(exit_status).to eql(0), output
          end
        end
      end
    end
  end

  context "with unknown language project" do
    context "with single repo" do
      it "prints an error and exits" do
        prepare_project :unknown_single
        output =
          capture_stdout do
            in_project { run_build }
          end

        expect(output).to include("UnknownLanguageError: Unknown language configured"), output
        expect(exit_status).to eql(1), output
      end
    end

    context "with mono repo" do
      it "builds the packages" do
        prepare_project :unknown_mono
        output =
          capture_stdout do
            in_project { run_build }
          end

        expect(output).to include("UnknownLanguageError: Unknown language configured"), output
        expect(exit_status).to eql(1), output
      end
    end
  end

  def run_build(args = [])
    Mono::Cli::Wrapper.new(["build"] + args).execute
  end
end
