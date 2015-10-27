$: << File.expand_path(File.dirname(__FILE__))
require 'active_support/inflector'

require 'vend/exception'
require 'vend/null_logger'
require 'vend/logable'
require 'vend/pagination_info'
require 'vend/scope'
require 'vend/resource_collection'
require 'vend/base_factory'
require 'vend/base'

require 'vend/resource/outlet'
require 'vend/resource/product'
require 'vend/resource/customer'
require 'vend/resource/payment_type'
require 'vend/resource/register'
require 'vend/resource/register_sale'
require 'vend/resource/register_sale_product'
require 'vend/resource/tax'
require 'vend/resource/user'

require 'vend/http_client'
require 'vend/client'

require 'vend/oauth2/client'
require 'vend/oauth2/auth_code'
