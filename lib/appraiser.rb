module AWSRuby
    require_relative '../data/spot_info'

    module Appraiser
        class << self
            def total_cost(num_instances:, spot_cost:, ebs_gb:, ebs_cost_gb_hour:)
                (num_instances * (spot_cost + (ebs_gb * ebs_cost_gb_hour))).round(2)
            end

            def cheapest_zone_per_instance(history:)
                history.map do |_, value|
                    value.group_by {|h| h[:availability_zone] }
                         .map { |_, value| value.max_by {|h| h[:timestamp] } }
                         .min_by {|h| h[:spot_price] }
                end
                .compact

            end
        end
    end
end