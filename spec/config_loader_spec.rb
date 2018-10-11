module AWSRuby

    require 'config_loader'

    RSpec.describe ConfigLoader do
        def test_cluster_conf(name, expected)
            expect(subject.cluster_conf(name)).to eq(expected)
        end

        let(:config_loader) { ConfigLoader.new(File.realdirpath('spec/configs')) }

        describe "#cluster_conf" do
            context "when parameter is empty" do
                name = ""
                expected = []

                it "returns empty array" do
                    expect(config_loader.cluster_conf(name)).to eq(expected)
                end
            end

            context "when parameter is not a string" do
                name = nil
                expected = []

                it "returns empty array" do
                    expect(config_loader.cluster_conf(name)).to eq(expected)
                end
            end

            context "when config name cannot be found" do
                name = "not_found"
                expected = []

                it "returns empty array" do
                    expect(config_loader.cluster_conf(name)).to eq(expected)
                end
            end

            context "when config name exists but extension is missing" do
                name = "test"
                expected = [
                    {
                        "instance_type" => "r5d.2xlarge",
                        "workers" => 30,
                        "ebs" => 0
                    },
                    {
                        "instance_type" => "r5d.4xlarge",
                        "workers" => 20,
                        "ebs" => 0
                    }
                ]

                it "returns the config" do
                    expect(config_loader.cluster_conf(name)).to eq(expected)
                end
            end

            context "when config name exists" do
                name = "test.json"
                expected = [
                    {
                        "instance_type" => "r5d.2xlarge",
                        "workers" => 30,
                        "ebs" => 0
                    },
                    {
                        "instance_type" => "r5d.4xlarge",
                        "workers" => 20,
                        "ebs" => 0
                    }
                ]

                it "returns the config" do
                    expect(config_loader.cluster_conf(name)).to eq(expected)
                end
            end
        end
    end

end