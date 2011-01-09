require 'will_paginate/collection'

# =Pagination for api resource collections
# Will paginate adapter for the api client.  Utilizes the same interface as will paginate and returns the 
# same WillPaginate::Collection for finder results.
module FlexmlsApi
  module Paginate
    # == Replacement hook for will_paginate's class method
    # Does a best effort to mimic the will_paginate method of same name.  All arguments are
    # passed on to the finder method except the special keys for the options hash listed below.
    #
    # == Special parameters for paginating finders
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to <tt>CurrentModel.per_page</tt> (which is 30 if not overridden)
    # * <tt>:finder</tt> -- name of the finder used (default: "get").  This needs to be a class finder method on the class
    def paginate(*args)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      page = options.delete(:page) || 1
      per_page = options.delete(:per_page) || 25
      finder = (options.delete(:finder) || 'get').to_s
      page_options = {
        "_pagination" => 1,
        "_limit" => per_page,
        "_page" => page
      }
      options.merge!(page_options)
      args << options
      collection = send(finder,*args)
    end
    
    # == Instanciate class instances from array of hash representations.  
    # Needs to be called by all finders that would like to support paging.  Takes the hash result 
    # set from the request layer and instanciates instances of the class called for the finder.
    #
    # * result_array -- the results object returned from the api request layer.  An array of hashes.
    # 
    # :returns:
    #   An array of class instances for the Class of the calling finder
    def collect(result_array)
      collection = result_array.collect { |item| new(item)}
      result_array.replace(collection)
      result_array
    end
  end

  # ==Paginate Api Responses
  # Module use by the request layer to decorate the response's results array with paging support.
  # Pagination only happens if the response includes the pagination information as specified by the 
  # API.
  module PaginateResponse
    # ==Enable pagination
    # * results -- array of hashes representing api resources
    # * paging_hash -- the pagination response information from the api representing paging state.
    # 
    # :returns:
    #   The result set decorated as a WillPaginate::Collection
    def paginate_response(results, paging_hash)
      pager = Pagination.new(paging_hash)
      paged_results = WillPaginate::Collection.create(pager.current_page, pager.page_size, pager.total_rows) do |p|
        p.replace(results)
      end
      paged_results
    end
  end

  # ==Pagination
  #   Simple class representing the API's pagination response object
  class Pagination
    attr_accessor :total_rows, :page_size, :total_pages, :current_page
    def initialize(hash)
      @total_rows     = hash["TotalRows"]
      @page_size      = hash["PageSize"]
      @total_pages    = hash["TotalPages"]
      @current_page   = hash["CurrentPage"]
    end
  end
  
end