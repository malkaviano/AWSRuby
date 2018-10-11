module AWSRuby

    require 'appraiser'

    RSpec.describe Appraiser do

        describe ".total_cost" do
            shared_examples_for "calculating cluster cost" do |num_instances, spot_cost, ebs_gb, ebs_cost_gb_hour, expected|
                result = Appraiser.total_cost(num_instances, spot_cost, ebs_gb, ebs_cost_gb_hour)

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
    end

end