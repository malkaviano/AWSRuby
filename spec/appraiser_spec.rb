module AWSRuby

    require 'appraiser'

    RSpec.describe Appraiser do

        describe ".spot_cluster_cost" do
            shared_examples_for "calculating cluster cost" do |num_instances, spot_cost, ebs_gb, ebs_cost_gb_hour, expected|
                result = Appraiser.spot_cluster_cost(
                    num_instances: num_instances,
                    spot_cost: spot_cost,
                    ebs_gb: ebs_gb,
                    ebs_cost_gb_hour: ebs_cost_gb_hour
                )

                it "returns #{expected}" do
                    expect(result).to eq(expected)
                end
            end

            spot_cost = 0.5
            num_instances = 10

            context "when EBS is required" do
                ebs_gb = 100
                ebs_cost_gb_hour = 0.1 * (1 / 720.0)

                expected = 5.14

                it_behaves_like "calculating cluster cost",
                                num_instances,
                                spot_cost,
                                ebs_gb,
                                ebs_cost_gb_hour,
                                expected
            end

            context "when EBS is not required" do
                ebs_gb = 0
                ebs_cost_gb_hour = 0.1 * (1 / 720.0)

                expected = 5

                it_behaves_like "calculating cluster cost",
                                num_instances,
                                spot_cost,
                                ebs_gb,
                                ebs_cost_gb_hour,
                                expected
            end
        end

        describe ".cheapest_zone_per_instance" do

            context "when history contains only distinct zones per instance" do
                context "when prices are distinct" do
                    history = {
                        "r3" => [
                            {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.346500", :timestamp=>"2018-10-06 22:05:45 UTC"},
                            {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.139300", :timestamp=>"2018-10-06 21:49:03 UTC"},
                            {:availability_zone=>"us-east-1a", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.239300", :timestamp=>"2018-10-06 21:49:03 UTC"},
                            {:availability_zone=>"us-east-1b", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.439300", :timestamp=>"2018-10-06 21:49:03 UTC"}
                        ],
                        "c5"=> [
                            {:availability_zone=>"us-east-1c", :instance_type=>"c5", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.327700", :timestamp=>"2018-10-06 22:22:10 UTC"}
                        ],
                        "m5"=> []
                    }

                    expected = [
                        {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.139300", :timestamp=>"2018-10-06 21:49:03 UTC"},
                        {:availability_zone=>"us-east-1c", :instance_type=>"c5", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.327700", :timestamp=>"2018-10-06 22:22:10 UTC"}
                    ]

                    it "returns only cheapest zone entry per instance" do
                        expect(subject.cheapest_zone_per_instance(history: history)).to eq(expected)
                    end
                end

                context "when prices are not distinct" do
                    history = {
                        "r3" => [
                            {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1", :timestamp=>"2018-10-06 22:05:45 UTC"},
                            {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1", :timestamp=>"2018-10-06 21:49:03 UTC"},
                            {:availability_zone=>"us-east-1a", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"2", :timestamp=>"2018-10-06 21:49:03 UTC"},
                            {:availability_zone=>"us-east-1b", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"2", :timestamp=>"2018-10-06 21:49:03 UTC"}
                        ]
                    }

                    expected = [
                        {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1", :timestamp=>"2018-10-06 22:05:45 UTC"}
                    ]

                    it "returns the first min price" do
                        expect(subject.cheapest_zone_per_instance(history: history)).to eq(expected)
                    end
                end
            end

            context "when history contains repetitive zones per instance" do
                history = {
                    "r3" => [
                        {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"2", :timestamp=>"2018-10-06 22:05:45 UTC"},
                        {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1", :timestamp=>"2018-10-06 21:49:03 UTC"},
                        {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"5", :timestamp=>"2018-10-06 23:49:03 UTC"},
                        {:availability_zone=>"us-east-1a", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"3", :timestamp=>"2018-10-06 21:49:03 UTC"},
                        {:availability_zone=>"us-east-1b", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"4", :timestamp=>"2018-10-06 21:49:03 UTC"}
                    ]
                }

                expected = [
                    {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"2", :timestamp=>"2018-10-06 22:05:45 UTC"}
                ]

                it "returns the cheapest considering only the latest timestamps" do
                    expect(subject.cheapest_zone_per_instance(history: history)).to eq(expected)
                end
            end
        end
    end

end