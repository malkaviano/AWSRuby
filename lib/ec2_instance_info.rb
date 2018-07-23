module AWSRuby
    require_relative 'pod'

    class EC2InstanceInfo
        include Pod

        def initialize(params)
            super
        end
    end
end