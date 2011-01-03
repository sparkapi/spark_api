module FlexmlsApi
  module Models
    class Video < Base


      def self.find_by_listing_key(key, options = {})
        videos = []
        resp = FlexmlsApi.client.get("/listings/#{key}/videos", options)
        resp.collect { |video| videos.push(new(video)) }
        videos
      end

    end
  end
end
