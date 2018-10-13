module AWSRuby
    require_relative '../data/spot_info'

    module Appraiser
        class << self
            def cluster_cost(
                num_instances:,
                instance_cost:,
                ebs_gb:,
                ebs_cost_gb_hour:,
                extra_cost_instance:,
                extra_cost_cluster:
            )
                (
                    extra_cost_cluster + num_instances * (
                        instance_cost +
                        (ebs_gb * ebs_cost_gb_hour) +
                        extra_cost_instance
                    )
                ).round(2)
            end

            def cheapest_zone_for(history:)
                history.map do |_, value|
                    value.group_by {|h| h[:availability_zone] }
                         .map { |_, value| value.max_by {|h| h[:timestamp] } }
                         .min_by {|h| h[:spot_price] }
                end
                .compact
                .freeze
            end

            def clusters_best_costs(
                clusters_info:,
                cheapest_zones:,
                ebs_cost_gb_hour: 0,
                extra_cost_instance: 0,
                extra_cost_cluster: 0
            )
                return [].freeze if clusters_info.empty? or cheapest_zones.empty?

                clusters_info.map do |h|
                    cheapest_zone = cheapest_zones.select { |cz| cz[:instance_type] == h[:instance_type] }

                    unless cheapest_zone.empty? then
                        cz = cheapest_zone.pop
                        merged = h.merge(cz)

                        cost = cluster_cost(
                            num_instances: merged[:workers],
                            instance_cost: merged[:spot_price].to_f,
                            ebs_gb: merged[:ebs_gb],
                            ebs_cost_gb_hour: ebs_cost_gb_hour,
                            extra_cost_instance: extra_cost_instance,
                            extra_cost_cluster: extra_cost_cluster
                        )

                        merged.store(:cost_hour, cost)

                        merged
                    end
                end
                .compact
                .freeze
            end
        end
    end
end