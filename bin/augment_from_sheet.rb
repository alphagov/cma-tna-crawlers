#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/case_store/augment_from_sheet'

case_store = CMA::CaseStore.new

names = ARGV

sheets = if names.any?
           names.map { |name| CMA::Sheet.new(name) }
         else
           CMA::Sheet.all
         end

sheets.each do |sheet|
  puts "Augmenting with #{sheet.filename}"
  CMA::CaseStore::AugmentFromSheet.new(case_store, sheet).run!
end
