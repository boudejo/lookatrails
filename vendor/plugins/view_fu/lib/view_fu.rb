require "view_fu/tag_helper"
ActionView::Base.send :include, ViewFu::TagHelper

require "browser_detect/helper"
ActionView::Base.send :include, BrowserDetect::Helper

require "headliner/helper"
ActionView::Base.send :include, Headliner::Helper