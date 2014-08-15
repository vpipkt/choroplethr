#' @importFrom R6 R6Class
Choropleth = R6Class("Choropleth", 
  public = list(
    title        = "",    # title for map
    scale_name   = "",    # title for scale
    warn         = FALSE, # warn user on clipped or missing values                      
    ggplot_scale = NULL,  # override default scale
    
    # a choropleth map is defined by these 3 variables
    # a data.frame from a user that columns called "region" and "value"
    # a data.frame of a map
    # a data.frame that lists names, as they appear in map.df
    initialize = function(map.df, map.names, user.df)
    {
      # all input, regardless of map, is just a bunch of (region, value) pairs
      stopifnot(is.data.frame(user.df))
      stopifnot(c("region", "value") %in% colnames(user.df))
      private$user.df = user.df
      private$user.df = private$user.df[, c("region", "value")]
      
      private$map.df    = map.df
      private$map.names = map.names
    },

    # explain what num_buckets means
    render = function(num_buckets=7) {
      private::num_buckets = num_buckets
      
      self::prepare_map()
      
      # child classes will render the resulting data as they see fit
    }
  ),
  
  private = list(
    # the key objects for this class
    user.df       = NULL, # input from user
    map.df        = NULL, # geometry of the map
    choropleth.df = NULL, # result of binding user data with our map data
    map.names     = NULL, # a helper object that lists various naming conventions for the regions
    
    num_buckets   = 7,      # number of equally-sized buckets for scale. use continuous scale if 1
    regions       = NULL,   # if not NULL, only render the regions listed
    
    # If input comes in as "NY" but map uses "new york", rename the input to match the map
    rename_regions = function()
    {
      stop("Base classes should override this function")
    },    
    
    # perhaps user only want to view, e.g., states on the west coast
    clip = function() {
      stop("Base classes should override")
    },
    
    # for us, discretizing values means 
    # 1. breaking the values into num_buckets equal intervals
    # 2. formatting the intervals e.g. with commas
    #' @importFrom Hmisc cut2    
    discretize = function() 
    {
      if (is.numeric(private$user.df$value) && private$num_buckets > 1) {
        
        # if cut2 uses scientific notation,  our attempt to put in commas will fail
        scipen_orig = getOption("scipen")
        options(scipen=999)
        private$user.df$value = cut2(private$user.df$value, g = private$num_buckets)
        options(scipen=scipen_orig)
        
        levels(private$user.df$value) = sapply(levels(private$user.df$value), format_levels)
      }
    },
    
    bind = function() {
      stop("Base classes should override")
    },
    
    prepare_map = function()
    {
      # before a map can really be rendered, you need to ...
      private$rename_regions() # rename input regions (e.g. "NY") to match regions in map (e.g. "new york")
      private$clip() # clip the input - e.g. remove value for Washington DC on a 50 state map
      private$discretize() # discretize the input. normally people don't want a continuous scale
      private$bind() # bind the input values to the map values
    },
    
    get_scale = function()
    {
      if (!is.null(ggplot_scale)) 
      {
        ggplot_scale
      } else if (private$num_buckets == 1) {
        scale_fill_continuous(self::scale_name, labels=comma, na.value="black", limits=c(min, max))
      } else {
        scale_fill_brewer(self::scale_name, drop=FALSE, labels=comma, na.value="black")        
      }
    })
    
)