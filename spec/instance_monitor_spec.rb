module AWSRuby

    require 'require_aws'
    require 'instance_monitor'

    RSpec.describe InstanceMonitor do
        let(:ec2_client) { Aws::EC2::Client.new(stub_responses: true) }

        describe "#instance_info" do
            let(:client) do
                ec2_client.stub_responses(
                        :describe_instances,
                        ->(context) do
                            if context.params[:filters][0][:name] == "tag" then
                                Aws::EC2::Types::DescribeInstancesResult.new(
                                    {
                                        next_token: nil,
                                        reservations: [
                                            Aws::EC2::Types::Reservation.new(
                                                {
                                                    groups: [
                                                        Aws::EC2::Types::GroupIdentifier.new(
                                                            {
                                                                group_name: "gName",
                                                                group_id: "gId",
                                                            }
                                                        )
                                                    ],
                                                    instances: [
                                                        Aws::EC2::Types::Instance.new(
                                                            {
                                                                ami_launch_index: 0,
                                                                architecture: "arch",
                                                                client_token: "token",
                                                                ebs_optimized: true,
                                                                image_id: "image",
                                                                instance_id: "instanceId",
                                                                instance_lifecycle: "spot",
                                                                instance_type: "type",
                                                                spot_instance_request_id: "requestId"
                                                            }
                                                        )
                                                    ],
                                                    owner_id: "ownerId",
                                                    requester_id: "requesterId",
                                                    reservation_id: "reservationId"
                                                }
                                            )
                                        ]
                                    }
                                )
                            else
                                puts "fuk"
                                nil
                            end
                        end
                )

                ec2_client
            end

            let(:instance_monitor) { InstanceMonitor.new(client) }

            context "when the filter is empty" do
                it "returns nil" do
                    expect(instance_monitor.instance_info({})).to be_nil
                end
            end

            context "when the filter has no matches" do
                it "returns empty hash" do
                    expect(instance_monitor.instance_info(
                        {
                            filters: [
                                { name: 'wrong', values: ['value1', 'value2'] }
                            ]
                        }
                    )).to eq({})
                end
            end

            context "when the filter has matches" do
                expected = {
                    :reservations => [
                        {
                            :groups=>[
                                {:group_name=>"gName", :group_id=>"gId"}
                            ],
                            :instances=>[
                                {
                                    :ami_launch_index=>0,
                                    :image_id=>"image",
                                    :instance_id=>"instanceId",
                                    :instance_type=>"type",
                                    :architecture=>"arch",
                                    :client_token=>"token",
                                    :ebs_optimized=>true,
                                    :instance_lifecycle=>"spot",
                                    :spot_instance_request_id=>"requestId"
                                }
                            ],
                            :owner_id=>"ownerId",
                            :requester_id=>"requesterId",
                            :reservation_id=>"reservationId"
                        }
                    ]
                }

                it "returns hash with instance info" do
                    expect(instance_monitor.instance_info(
                        {
                            filters: [
                                { name: 'tag', values: ['value1', 'value2'] }
                            ]
                        }
                    )).to include(expected)
                end
            end
        end
    end
end