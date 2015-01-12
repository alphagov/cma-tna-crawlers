#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/case_store/augment_from_sheet'

case_store = CMA::CaseStore.new

CMA::Sheet.all.each do |sheet|
  puts "Augmenting with #{sheet.filename}"
  CMA::CaseStore::AugmentFromSheet.new(case_store, sheet).run!
end
