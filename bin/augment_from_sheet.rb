#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cma/case_store/augment_from_sheet'

CMA::CaseStore::AugmentFromSheet.new(
  CMA::CaseStore.new,
  CMA::Sheet.new('sheets/consumer-enforcement.csv')
).run!
