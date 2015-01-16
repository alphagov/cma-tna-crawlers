#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/oft/competition/crawler'

CMA::OFT::Competition::Crawler.new.crawl!
