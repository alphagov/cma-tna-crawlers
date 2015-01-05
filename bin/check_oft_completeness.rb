#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/oft/check_completeness_crawler'

CMA::OFT::CheckCompletenessCrawler.new.crawl!
