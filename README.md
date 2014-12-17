# CMA TNA Crawlers

This repo crawls The National Archives (hereafter TNA) for these closed sites:

1. Competition Commission (hereafter CC)
2. Office of Fair Trading (hereafter OFT)

## Usage

There are executable scripts in `bin` that will run the crawlers. By default,
cases will be saved to a dir `_output` relative to whatever dir you run them
from. For example, running

```
  bin/crawl_cc
```

...from here will produce an `_output` directory with one JSON file per case and
one directory named for the case containing any PDFs associated with that case.

Both crawlers are whitelist crawlers - they only follow links we say are of
interest via Anemone's `focus_crawl`. In the case of both CC and OFT sites we
can tell for any URL in the page what type of thing it will link to, and
that makes the crawl time significantly quicker - we can tell whether to follow
an `href` without having to dereference it. The downside is some fairly funky
regular expressions in each `Crawler` class. Sorry about that, clarity fans.

`crawl_oft` is to some extent incomplete. To see the current state of work,
please check the [Issues](https://github.com/rgarner/cma-tna-crawlers/issues).
