#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/cc/case_list/crawler'
require 'cma/cc/case_crawler'

# Two crawlers. Get the whole case list first, then fill in detail.
CMA::CC::CaseList::Crawler.new.crawl!
CMA::CC::CaseCrawler.new.crawl!
