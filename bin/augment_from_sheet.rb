#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/case_store/augment_from_sheet'

case_store = CMA::CaseStore.new

name = ARGV[0]

sheets = name ? [CMA::Sheet.new(name)] : CMA::Sheet.all

sheets.each do |sheet|
  puts "Augmenting with #{sheet.filename}"
  CMA::CaseStore::AugmentFromSheet.new(case_store, sheet).run!
end
