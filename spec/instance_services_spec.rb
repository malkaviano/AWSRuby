module AWSRuby

require 'require_aws'
require 'instance_services'

RSpec.describe InstanceServices do

    let(:ec2_client) { Aws::EC2::Client.new(stub_responses: true) }

    let(:stubbed_client) { InstanceServices.new(client) }

    describe "#spot_price_history" do

        let(:client) do
            ec2_client.stub_responses(
                    :describe_spot_price_history,
                    ->(context) do
                        if (context.params.empty?) then
                            Aws::EC2::Types::DescribeSpotPriceHistoryResult.new(
                                :spot_price_history => []
                            )
                        else
                            Aws::EC2::Types::DescribeSpotPriceHistoryResult.new(
                                :spot_price_history => [
                                    Aws::EC2::Types::SpotPrice.new(
                                        {
                                            :availability_zone=>"us-east-1a",
                                            :instance_type=>"r3.xlarge",
                                            :product_description=>"Linux/UNIX (Amazon VPC)",
                                            :spot_price=>"1.325900",
                                            :timestamp=>"2018-10-06 22:39:01 UTC"
                                        }
                                    ),
                                    Aws::EC2::Types::SpotPrice.new(
                                        {
                                            :availability_zone=>"us-east-1b",
                                            :instance_type=>"r3.xlarge",
                                            :product_description=>"Linux/UNIX (Amazon VPC)",
                                            :spot_price=>"0.697400",
                                            :timestamp=>"2018-10-06 22:22:12 UTC"
                                        }
                                    ),
                                    Aws::EC2::Types::SpotPrice.new(
                                        {
                                            :availability_zone=>"us-east-1c",
                                            :instance_type=>"r3.xlarge",
                                            :product_description=>"Linux/UNIX (Amazon VPC)",
                                            :spot_price=>"0.327700",
                                            :timestamp=>"2018-10-06 22:22:10 UTC"
                                        }
                                    ),
                                    Aws::EC2::Types::SpotPrice.new(
                                        {
                                            :availability_zone=>"us-east-1d",
                                            :instance_type=>"r3.2xlarge",
                                            :product_description=>"Linux/UNIX (Amazon VPC)",
                                            :spot_price=>"0.346500",
                                            :timestamp=>"2018-10-06 22:05:45 UTC"
                                        }
                                    ),
                                    Aws::EC2::Types::SpotPrice.new(
                                        {
                                            :availability_zone=>"us-east-1e",
                                            :instance_type=>"r3.2xlarge",
                                            :product_description=>"Linux/UNIX (Amazon VPC)",
                                            :spot_price=>"0.139300",
                                            :timestamp=>"2018-10-06 21:49:03 UTC"
                                        }
                                    )
                                ]
                            )
                        end
                    end
                )

            ec2_client
        end

        shared_examples_for "getting history for instances" do |msg|
            it "returns #{msg}" do
                result = stubbed_client.spot_price_history(filter: filter)

                expect(result).to include(expected)
            end

            it "returns frozen objs" do
                result = stubbed_client.spot_price_history(filter: filter)

                expect(result.frozen?).to be true
            end
        end

        context "when there are results" do

            let(:filter) { {:instance_types => ["some"]} }

            let(:expected) {
                {
                    "r3.2xlarge" => [
                        {:availability_zone=>"us-east-1d", :instance_type=>"r3.2xlarge", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.346500", :timestamp=>"2018-10-06 22:05:45 UTC"},
                        {:availability_zone=>"us-east-1e", :instance_type=>"r3.2xlarge", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.139300", :timestamp=>"2018-10-06 21:49:03 UTC"}
                    ],
                    "r3.xlarge"=> [
                        {:availability_zone=>"us-east-1a", :instance_type=>"r3.xlarge", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"1.325900", :timestamp=>"2018-10-06 22:39:01 UTC"},
                        {:availability_zone=>"us-east-1b", :instance_type=>"r3.xlarge", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.697400", :timestamp=>"2018-10-06 22:22:12 UTC"},
                        {:availability_zone=>"us-east-1c", :instance_type=>"r3.xlarge", :product_description=>"Linux/UNIX (Amazon VPC)", :spot_price=>"0.327700", :timestamp=>"2018-10-06 22:22:10 UTC"}
                    ]
                }
            }

            it_behaves_like "getting history for instances", "aggregated results per instance type"
        end

        context "when there are no results" do
            let(:filter) { {} }

            let(:expected) { {} }

            it_behaves_like "getting history for instances", "empty hash"
        end
    end

    describe "#terminate_instances" do

        let(:client) do
            ec2_client.stub_responses(
                    :terminate_instances,
                    ->(context) do
                        unless context.params[:instance_ids].empty? then
                            Aws::EC2::Types::TerminateInstancesResult.new(
                                {
                                    terminating_instances: [
                                        Aws::EC2::Types::InstanceStateChange.new(
                                            {
                                                current_state: Aws::EC2::Types::InstanceState.new(
                                                    {
                                                        code: 32,
                                                        name: "shutting-down"
                                                    }
                                                ),
                                                instance_id: "xpto",
                                                previous_state: Aws::EC2::Types::InstanceState.new(
                                                    {
                                                        code: 16,
                                                        name: "running"
                                                    }
                                                )
                                            }
                                        ),
                                        Aws::EC2::Types::InstanceStateChange.new(
                                            {
                                                current_state: Aws::EC2::Types::InstanceState.new(
                                                    {
                                                        code: 32,
                                                        name: "shutting-down"
                                                    }
                                                ),
                                                instance_id: "xpto2",
                                                previous_state: Aws::EC2::Types::InstanceState.new(
                                                    {
                                                        code: 16,
                                                        name: "running"
                                                    }
                                                )
                                            }
                                        )
                                    ]
                                }
                            )
                        else
                            Aws::EC2::Types::TerminateInstancesResult.new(
                                {
                                    terminating_instances: []
                                }
                            )
                        end
                    end
                )

            ec2_client
        end

        shared_examples_for "terminating instances" do |msg|

            it "returns #{msg}" do
                result = stubbed_client.terminate_instances(ids: filter)

                expect(result).to eq(expected)
            end

            it "returns frozen objs" do
                result = stubbed_client.terminate_instances(ids: filter)

                expect(result.frozen?).to be true
            end
        end

        context "when ids are not found" do
            let(:filter) { [] }

            let(:expected) {
                {
                    :terminating_instances => []
                }
             }

            it_behaves_like "terminating instances", "empty array"
        end

        context "when ids are found" do
            let(:filter) { [ "xpto", "xpto2" ] }

            let(:expected) {
                {
                    :terminating_instances => [
                        {
                            current_state:
                            {
                                code: 32,
                                name: "shutting-down"
                            },
                            instance_id: "xpto",
                            previous_state:
                            {
                                code: 16,
                                name: "running"
                            }
                        },
                        {
                            current_state:
                            {
                                code: 32,
                                name: "shutting-down"
                            },
                            instance_id: "xpto2",
                            previous_state:
                            {
                                code: 16,
                                name: "running"
                            }
                        }
                    ]
                }
            }

            it_behaves_like "terminating instances", "array with results for ids"
        end
    end
end

end