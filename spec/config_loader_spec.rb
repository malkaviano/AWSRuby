module AWSRuby

    require 'config_loader'

    RSpec.describe ConfigLoader do
        shared_examples_for "configuration loading" do |m|
            let(:config_loader) { ConfigLoader.new(config_dir: File.realdirpath("spec/configs")) }

            it "returns a frozen obj" do
                expect(config_loader.send(m, name: "").frozen?).to be true

                expect(config_loader.send(m, name: "teste.json").frozen?).to be true
            end

            context "when parameter is empty" do
                name = ""

                it "returns empty array" do
                    expect(config_loader.send(m, name: name)).to eq(wrong)
                end
            end

            context "when parameter is not a string" do
                name = nil

                it "returns empty array" do
                    expect(config_loader.send(m, name: name)).to eq(wrong)
                end
            end

            context "when config name cannot be found" do
                name = "not_found"

                it "returns empty array" do
                    expect(config_loader.send(m, name: name)).to eq(wrong)
                end
            end

            context "when config name exists but extension is missing" do
                name = "test"

                it "returns the config" do
                    expect(config_loader.send(m, name: name)).to eq(right)
                end
            end

            context "when config name exists" do
                name = "test.json"

                it "returns the config" do
                    expect(config_loader.send(m, name: name)).to eq(right)
                end
            end
        end

        describe "#cluster_conf" do
            let(:wrong) { [] }

            let(:right) {
                [
                    {
                        instance_type: "r5d.2xlarge",
                        workers: 30,
                        ebs_gb: 0
                    },
                    {
                        instance_type: "r5d.4xlarge",
                        workers: 20,
                        ebs_gb: 0
                    }
                ]
            }
            it_behaves_like "configuration loading",
                            :cluster_conf
        end

        describe "#filter_conf" do
            let(:wrong) { {} }

            let(:right) {
                {
                    name: "teste",
                    instance_type: "i3.xlarge"
                }
            }

            it_behaves_like "configuration loading",
                            :filter_conf

        end
    end

end