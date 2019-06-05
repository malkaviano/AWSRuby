module AWSRuby

require 'require_aws'
require 'spot_client'

RSpec.describe SpotClient do

    let(:ec2_client) { Aws::EC2::Client.new(stub_responses: true) }

    describe "#history_for" do
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

        let(:spot_client) { SpotClient.new(client) }

        context "when there are results" do
            expected = {
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


            it "returns aggregated results per instance type" do
                result = spot_client.history_for({:instance_types => ["some"]})

                expect(result).to include(expected)
            end
        end

        context "when there are no results" do
            it "returns empty hash" do
                result = spot_client.history_for({})

                expect(result).to eq({})
            end
        end
    end

    describe "#terminate_instances" do

        let(:client) do
            ec2_client.stub_responses(
                    :terminate_instances,
                    ->(context) do
                        if context.params[:instance_ids].include? "xpto" then
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
                                        )
                                    ]
                                }
                            )
                        else
                           
                        end
                    end
                )
    
            ec2_client
        end

        let(:spot_client) { SpotClient.new(client) }

        context "when ids is empty" do
            it "returns nil" do
                expect(spot_client.terminate_instances([])).to be_nil
            end
        end

        context "when ids is not empty" do
            it "returns results for ids found" do
                result = spot_client.terminate_instances([ "xpto", "not_found" ])

                expected = {
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
                }

                expect(result[:terminating_instances].pop).to eq(expected)
            end
        end
    end
end

end