#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/oft/completed_crawler'

CMA::OFT::CompletedCrawler.new.crawl!
