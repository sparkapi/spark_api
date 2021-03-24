require 'net/http'
module SparkApi
  module Models
    class Video < Base
      extend Subresource
      include Media
      include Concerns::Savable,
              Concerns::Destroyable

      # Regex to find YouTube's and Vimeo's video ID
      YOUTUBE_REGEX = %r(^(http[s]*:\/\/)?(www.)?(youtube.com|youtu.be)\/(watch\?v=){0,1}([a-zA-Z0-9_-]{11}))
      VIMEO_REGEX = %r(^https?:\/\/(?:.*?)\.?(vimeo)\.com\/(\d+).*$)

      self.element_name = 'videos'

      def branded?
        attributes['Type'] == 'branded'
      end

      def unbranded?
        attributes['Type'] == 'unbranded'
      end

      def url
        attributes['ObjectHtml']
      end

      def description
        attributes['Name']
      end

      # Some youtube URLS are youtu.be instead of youtube
      SUPPORTED_VIDEO_TYPES = %w[vimeo youtu].freeze

      def is_supported_type?
        # Unfortunately there are so many formats of vimeo videos that we canot support all vimeo videos
        # Therefore, we need to do a little more checking here and validate that we can get video codes out of the urls
        (self.ObjectHtml.include?('youtu') && youtube_video_code.present?) || (self.ObjectHtml.include?('vimeo') && vimeo_video_code.present?)
      end

      def is_valid_iframe?
        self.ObjectHtml.include?('<iframe') && self.ObjectHtml.include?('</iframe>')
      end

      # gets the thumbnail to be shown on supported (Vimeo and Youtube) videos
      # YouTube provides a predictable url for each video's images
      # for Vimeo, a get request is necessary
      def display_image
        url = self.video_link
        if url
          if(url.include?('youtube'))
            youtube_thumbnail_url
          else 
            vimeo_thumbnail_url
          end
        end
      end

      def video_link
        return nil unless is_supported_type?

        if self.ObjectHtml.include?('youtu')
            youtube_link
        elsif self.ObjectHtml.include?('vimeo')
            vimeo_link
        end
      end

      def get_video_in_iframe(width: "560px", height: "315px")
        if find_vimeo_id(url)
          get_vimeo_iframe(url, width, height) 
        elsif find_youtube_id(url)
          get_youtube_iframe(url, width, height) 
        end
      end

      private

      def vimeo_video_code
        html = self.ObjectHtml
        if html.match(/(src=)('|")((https:)?\/\/player\.vimeo\.com\/video\/)/)
          new_url = html.split(/(src=')|(src=")/)
          if new_url[2]
            html = new_url[2].split(/("|')/)[0]
          end
        end
        if html.match(/(?:.+?)?(player\.vimeo\.com|vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/([^\/]*)\/videos\/|album\/(\d+)\/video\/|)(\d+)(?:$|\/|\?))/)
          code = html.split('/').last.split('?').first
          # Vimeo Ids are always numerical
          code.to_i.to_s === code ? code : nil
        else
          nil
        end
      end

      # This if correctly embedded by the user is an embed
      # If not, it could be pretty much anything
      def youtube_video_code
        html = self.ObjectHtml
        if html.match(/(?:.+?)?(?:\/v\/|watch\/|\?v=|\&v=|youtu\.be\/|\/v=|^youtu\.be\/|embed\/|watch\%3Fv\%3D)([a-zA-Z0-9_-]{11})/) || html.match(/(iframe)(.*)(src=)('|")(https:\/\/www\.youtube\.com\/embed)/)
          html.split(/([a-zA-Z0-9_-]{11})/)[1]
        else
          nil
        end
      end

      def youtube_link
        normalize_youtube_url
        code = youtube_video_code
        code ? "https://www.youtube.com/watch?v=#{code}" : nil
      end

      def vimeo_link
        code = vimeo_video_code
        code ? "https://vimeo.com/#{code}" : nil
      end

      def youtube_thumbnail_url
        code = youtube_video_code
        code ? "https://i1.ytimg.com/vi/#{code}/hqdefault.jpg" : nil
      end

      def vimeo_thumbnail_url
        # due to the rate limiting issue that surfaced shortly before launch,
        # we will temporarily not return vimeo thumbnails until
        # there is bandwidth to implement the solution in FLEX-9959
        return nil
      end

      def normalize_youtube_url
        self.ObjectHtml.sub!('-nocookie', '')
      end

      def find_youtube_id full_url
        matches = YOUTUBE_REGEX.match full_url.to_str
        if matches
          matches[6] || matches[5]
        end
      end

      def get_youtube_iframe full_url, width, height
        youtube_id = find_youtube_id full_url

        result = %(<iframe title="YouTube video player" width="#{width}"
                    height="#{height}" src="//www.youtube.com/embed/#{ youtube_id }"
                    frameborder="0" allowfullscreen></iframe>)
        result.html_safe
      end

      def find_vimeo_id full_url
        matches = VIMEO_REGEX.match full_url.to_str
        matches[2] if matches
      end

      def get_vimeo_iframe full_url, width, height
        vimeo_id = find_vimeo_id full_url
        uri = "https://vimeo.com/api/oembed.json?url=https%3A//vimeo.com/#{ vimeo_id }&width=#{ width }&height=#{ height }"
        response = Net::HTTP.get( URI.parse( uri ))
        json = JSON.parse response
        json['html'].html_safe
      end
      
    end
  end
end
