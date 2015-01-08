#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/oft/mergers_crawler'

CMA::OFT::MergersCrawler.new.crawl!
