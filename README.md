# CMA TNA Crawlers

This repo crawls The National Archives (hereafter TNA) for these closed sites:

1. Competition Commission (hereafter CC)
2. Office of Fair Trading (hereafter OFT)

## Usage

This solution is part crawler, part CSV-based. We get occasional spreadsheets
from CMA as `.xslx` files. These are exported as CSV and placed in
[./sheets](sheets).

The crawlers should be run first, followed by `augment_from_sheet`, then any
body generators.

There are executable scripts in `bin` that will run the crawlers. By default,
cases will be saved to a dir `_output` relative to whatever dir you run them
from. For example, running

```
  bin/crawl_cc
```

...from here will produce an `_output` directory with one JSON file per case and
one directory named for the case containing any PDFs associated with that case.

The crawlers are whitelist crawlers - they only follow links we say are of
interest via Anemone's `focus_crawl`. In the case of both CC and OFT sites we
can tell for any URL in the page what type of thing it will link to, and
that makes the crawl time significantly quicker - we can tell whether to follow
an `href` without having to dereference it. The downside is some fairly funky
regular expressions in each `Crawler` class. Sorry about that, clarity fans.

### `crawl_cc`

Crawls the CC site. It collates body copy from different pages into a
`markup_sections` hash. When finished, you should run `generate_cc_bodies`.

### `crawl_oft_mergers`

Crawls the mergers for years from the start URLs in `CMA::OFT::Mergers::Crawler`.

#### For newer cases (2010-2014)

it creates JSON files with summaries and links to the PDF assets describing
the decisions. No body is created.

#### For older cases (2002-2009)

it collates markup sections describing the decisions in a similar manner to the
CC crawler. We will need a body generator for these mergers, so we'll need to
come up with some rules.

### `crawl_oft_current`

Crawls competition/cartels, markets and consumer enforcement cases. Note that
we will need to remove markets from this and put them in their own crawler, as
only 14 closed markets cases will go over.

### `crawl_oft_completed`

Adds to output from `crawl_current` by looking at the completed pages. Some
cases exist on these pages that aren't listed in the year case lists at
`crawl_oft_current`.

## Body generators

### `generate_cc_bodies`

Generates `summary` and `body` for each piece of CC json from collated
markup sections according to some formatting rules.

### `generate_mergers_bodies`

TBD

## Current status

For current status of work, please check the
[Issues](https://github.com/rgarner/cma-tna-crawlers/issues).
