module OnCue

  module Parameters

    def self.convert_param_values_to_strings(params)
      return nil if params.nil?
      raise ArgumentError.new('Params must be nil or a hash') unless params.kind_of? Hash
      updated_params = {}
      params.each do |k, v|
        if v.nil?
          updated_params[k] = nil
        else
          updated_params[k] = v.to_s
        end
      end
      updated_params
    end

  end

end