require 'cma/oft/current/case'

module CMA
  module OFT
    module Competition
      class Case < CMA::OFT::Current::Case
        def case_type
          title =~ /^Criminal/ ? 'criminal-cartels' : 'ca98-and-civil-cartels'
        end
      end
    end
  end
end
