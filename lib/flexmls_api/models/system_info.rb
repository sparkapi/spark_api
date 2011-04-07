module FlexmlsApi
  module Models
    class SystemInfo < Base
      self.element_name="system"

      def primary_logo
        logo = nil
	mls_logos = attributes['Configuration'].first['MlsLogos']
	if !mls_logos.nil? and !mls_logos.empty?
	  logo = mls_logos.first
	end
	logo
      end
    end
  end
end
