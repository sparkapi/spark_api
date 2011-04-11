module FlexmlsApi
  module Models
    class SystemInfo < Base
      self.element_name="system"

      def primary_logo
        logo = nil
        mls_logos = attributes['Configuration'].first['MlsLogos']
        logo = mls_logos.first if !mls_logos.nil? and !mls_logos.empty?
        logo
      end
    end
  end
end
