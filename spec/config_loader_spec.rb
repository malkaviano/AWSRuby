module AWSRuby

    require 'config_loader'

    RSpec.describe ConfigLoader do
        shared_examples_for "configuration loading" do |m, wrong, right|
            let(:config_loader) { ConfigLoader.new(File.realdirpath("spec/configs")) }

            context "when parameter is empty" do
                name = ""
                expected = wrong

                it "returns empty array" do
                    expect(config_loader.send(m, name)).to eq(expected)
                end
            end

            context "when parameter is not a string" do
                name = nil
                expected = wrong

                it "returns empty array" do
                    expect(config_loader.send(m, name)).to eq(expected)
                end
            end

            context "when config name cannot be found" do
                name = "not_found"
                expected = wrong

                it "returns empty array" do
                    expect(config_loader.send(m, name)).to eq(expected)
                end
            end

            context "when config name exists but extension is missing" do
                name = "test"
                expected = right

                it "returns the config" do
                    expect(config_loader.send(m, name)).to eq(expected)
                end
            end

            context "when config name exists" do
                name = "test.json"
                expected = right

                it "returns the config" do
                    expect(config_loader.send(m, name)).to eq(expected)
                end
            end
        end

        describe "#cluster_conf" do
            it_behaves_like "configuration loading",
                            :cluster_conf,
                            [],
                            [
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
        end

        describe "#filter_conf" do
            it_behaves_like "configuration loading",
                            :filter_conf,
                            [],
                            [

                            ]
        end
    end

end