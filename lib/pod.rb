module AWSRuby
    require_relative 'value'

    module Pod
        include Value

        def initialize(params)
            params.each do |key, value|
                self.class.send(:define_method, "#{key}=".to_sym) do |value|
                    instance_variable_set("@" + key.to_s, value)
                end
            end

            super
        end
    end
end