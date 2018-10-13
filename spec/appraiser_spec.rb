module AWSRuby

    require 'appraiser'

    RSpec.describe Appraiser do
## TODO: Fix decimal point equality
        describe ".cluster_cost" do
            shared_examples_for "calculating cluster cost" do |num_instances, instance_cost, ebs_gb, ebs_cost_gb_hour, expected|
                it "returns #{expected}" do
                    result = Appraiser.cluster_cost(
                        num_instances: num_instances,
                        instance_cost: instance_cost,
                        ebs_gb: ebs_gb,
                        ebs_cost_gb_hour: ebs_cost_gb_hour,
                        extra_cost_instance: extra_cost_instance,
                        extra_cost_cluster: extra_cost_cluster
                    )

                    expect(result).to eq(expected)
                end
            end

            instance_cost = 0.5
            num_instances = 10

            context "when EBS is required" do
                ebs_gb = 100
                ebs_cost_gb_hour = 0.1 * (1 / 720.0)

                expected = 25.14

                let(:extra_cost_instance) { 1 }
                let(:extra_cost_cluster) { 10 }

                it_behaves_like "calculating cluster cost",
                                num_instances,
                                instance_cost,
                                ebs_gb,
                                ebs_cost_gb_hour,
                                expected
            end

            context "when EBS is not required" do
                ebs_gb = 0
                ebs_cost_gb_hour = 0.1 * (1 / 720.0)

                expected = 5

                let(:extra_cost_instance) { 0 }
                let(:extra_cost_cluster) { 0 }

                it_behaves_like "calculating cluster cost",
                                num_instances,
                                instance_cost,
                                ebs_gb,
                                ebs_cost_gb_hour,
                                expected
            end
        end

        describe ".cheapest_zone_for" do
            shared_examples_for "filtering cheapest zones for instance" do
                it "returns the cheapest zone per instance" do
                    expect(subject.cheapest_zone_for(history: history)).to eq(expected)
                end

                it "returns a frozen obj" do
                    expect(subject.cheapest_zone_for(history: history).frozen?).to be true
                end
            end

            context "when history contains only distinct zones per instance" do
                context "when prices are distinct" do
                    let(:history) {
                        {
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
                    }

                    let(:expected) {
                        [
                            {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.139300", :timestamp=>"2018-10-06 21:49:03 UTC"},
                            {:availability_zone=>"us-east-1c", :instance_type=>"c5", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.327700", :timestamp=>"2018-10-06 22:22:10 UTC"}
                        ]
                    }

                    it_behaves_like "filtering cheapest zones for instance"
                end

                context "when prices are not distinct" do
                    let(:history) {
                        {
                            "r3" => [
                                {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1", :timestamp=>"2018-10-06 22:05:45 UTC"},
                                {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1", :timestamp=>"2018-10-06 21:49:03 UTC"},
                                {:availability_zone=>"us-east-1a", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"2", :timestamp=>"2018-10-06 21:49:03 UTC"},
                                {:availability_zone=>"us-east-1b", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"2", :timestamp=>"2018-10-06 21:49:03 UTC"}
                            ]
                        }
                    }

                    let(:expected) {
                        [
                            {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1", :timestamp=>"2018-10-06 22:05:45 UTC"}
                        ]
                    }

                    it_behaves_like "filtering cheapest zones for instance"
                end
            end

            context "when history contains repetitive zones per instance" do
                let(:history) {
                    {
                        "r3" => [
                            {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"2", :timestamp=>"2018-10-06 22:05:45 UTC"},
                            {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1", :timestamp=>"2018-10-06 21:49:03 UTC"},
                            {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"5", :timestamp=>"2018-10-06 23:49:03 UTC"},
                            {:availability_zone=>"us-east-1a", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"3", :timestamp=>"2018-10-06 21:49:03 UTC"},
                            {:availability_zone=>"us-east-1b", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"4", :timestamp=>"2018-10-06 21:49:03 UTC"}
                        ]
                    }
                }

                let(:expected) {
                    [
                        {:availability_zone=>"us-east-1d", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"2", :timestamp=>"2018-10-06 22:05:45 UTC"}
                    ]
                }

                it_behaves_like "filtering cheapest zones for instance"
            end
        end

        describe ".clusters_best_costs" do
            shared_examples_for "showing cheapest zone for clusters" do
                it "returns array with zone, cost and cluster info" do
                    expect(
                        subject.clusters_best_costs(
                            clusters_info: clusters_info,
                            cheapest_zones: cheapest_zones,
                            ebs_cost_gb_hour: 1
                        )
                    ).to match_array(expected)
                end

                it "returns a frozen obj" do
                    expect(
                        subject.clusters_best_costs(
                            clusters_info: clusters_info,
                            cheapest_zones: cheapest_zones,
                            ebs_cost_gb_hour: 1
                        ).frozen?
                    ).to be true
                end
            end

            context "when clusters info is empty" do
                let(:clusters_info) { [] }

                let(:cheapest_zones) {
                    [
                        {:availability_zone=>"us-east-1e", :instance_type=>"r3", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.139300", :timestamp=>"2018-10-06 21:49:03 UTC"},
                        {:availability_zone=>"us-east-1c", :instance_type=>"c5", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.327700", :timestamp=>"2018-10-06 22:22:10 UTC"}
                    ]
                }

                let(:expected) { [] }

                it_behaves_like "showing cheapest zone for clusters"
            end

            context "when cheapest zone list is empty" do
                let(:clusters_info) {
                    [
                        {instance_type: "r5d", workers: 40, ebs_gb: 0},
                        {instance_type: "m4", workers: 30, ebs_gb: 0},
                        {instance_type: "c3", workers: 20, ebs_gb: 0}
                    ]
                }

                let(:cheapest_zones) { [] }

                let(:expected) { [] }

                it_behaves_like "showing cheapest zone for clusters"
            end

            context "when there are info for clusters and prices" do
                let(:clusters_info) {
                    [
                        {instance_type: "r5d", workers: 10, ebs_gb: 100},
                        {instance_type: "m4", workers: 10, ebs_gb: 100},
                        {instance_type: "c3", workers: 10, ebs_gb: 100},
                        {instance_type: "h1", workers: 10, ebs_gb: 100}
                    ]
                }

                let(:cheapest_zones) {
                    [
                        {
                            :availability_zone=>"us-east-1e",
                            :instance_type=>"r5d",
                            :product_description=>"Linux/UNIX (Amazon VPC)",
                            :spot_price=>"5",
                            :timestamp=>"2018-10-06 21:49:03 UTC"
                        },
                        {
                            :availability_zone=>"us-east-1d",
                            :instance_type=>"m4",
                            :product_description=>"Linux/UNIX (Amazon VPC)",
                            :spot_price=>"3",
                            :timestamp=>"2018-10-06 21:49:03 UTC"
                        },
                        {
                            :availability_zone=>"us-east-1c",
                            :instance_type=>"c3",
                            :product_description=>"Linux/UNIX (Amazon VPC)",
                            :spot_price=>"2",
                            :timestamp=>"2018-10-06 21:49:03 UTC"
                        },
                        {
                            :availability_zone=>"us-east-1a",
                            :instance_type=>"g2",
                            :product_description=>"Linux/UNIX (Amazon VPC)",
                            :spot_price=>"1",
                            :timestamp=>"2018-10-06 21:49:03 UTC"
                        }
                    ]
                }

                let(:expected) {
                    [
                        {
                            :instance_type=>"r5d",
                            :workers=>10,
                            :ebs_gb=>100,
                            :availability_zone=>"us-east-1e",
                            :product_description=>"Linux/UNIX (Amazon VPC)",
                            :spot_price=>"5",
                            :timestamp=>"2018-10-06 21:49:03 UTC",
                            :cost_hour=>1050.0
                        },
                        {
                            :instance_type=>"m4",
                            :workers=>10,
                            :ebs_gb=>100,
                            :availability_zone=>"us-east-1d",
                            :product_description=>"Linux/UNIX (Amazon VPC)",
                            :spot_price=>"3",
                            :timestamp=>"2018-10-06 21:49:03 UTC",
                            :cost_hour=>1030.0
                        },
                        {
                            :instance_type=>"c3",
                            :workers=>10,
                            :ebs_gb=>100,
                            :availability_zone=>"us-east-1c",
                            :product_description=>"Linux/UNIX (Amazon VPC)",
                            :spot_price=>"2",
                            :timestamp=>"2018-10-06 21:49:03 UTC",
                            :cost_hour=>1020.0
                        }
                    ]
                }

                it_behaves_like "showing cheapest zone for clusters"
            end
        end
    end

end