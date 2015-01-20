require 'cma/oft/current/case'

module CMA
  module OFT
    module Markets
      class Case < CMA::OFT::Current::Case
        LIST   = %r{/OFTwork/markets-work/references/?$}

        DETAIL_PATTERN = %r{(?:[a-z]+-terms)|(?:varied)}

        CORE         = %r{/OFTwork/markets-work/references/(?!#{DETAIL_PATTERN})[a-z|A-Z|0-9|-]+/?$}
        DETAIL       = %r{/OFTwork/markets-work/[a-z|A-Z|0-9|-]+/?$}x
        EXTRA_DETAIL = %r{/OFTwork/markets-work/references/#{DETAIL_PATTERN}/?$}x

        def case_type
          'markets'
        end

        def add_subpage(doc)
          original_url = original_url_from_meta(doc)

          markup_sections[section_name(original_url)] = subpage_content_for(doc)

          original_urls << www(original_url)
        end

        def section_name(original_url)
          case original_url
          when CORE         then 'core-documents'
          when DETAIL       then 'detail'
          when EXTRA_DETAIL then 'extra-detail'
          end
        end
      end
    end
  end
end
