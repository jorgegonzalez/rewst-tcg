#!/usr/bin/env bash
# This script generates markdown from the output of the `tree` command.
# See: https://linux.die.net/man/1/tree
# See: https://gist.github.com/kflorence/7f18ad97c65337ef77d37159260a331d

set -e

# Tree is configured with:
# - `-f`: use full paths in output (relative to directory given, in this case '.').
# - `--noreport`: exclude the directories and files report as the last line of output.
# - `-I "readme.md"`: exclude any "readme.md" files, redundant with the link to the directory containing that file.
# - `-P "*.md"`: only include Markdown files (files ending with ".md").
# - `--charset ascii`: use ASCII characters instead of unicode (makes parsing easier).
# - `--sort=name`: sort the tree structure by name, alphabetical.
#
# There are then a series of sed commands. These commands:
# - remove any lines ending with `/images` (excludes /images folders).
# - remove any blank lines (cleans up after the above to remove lines that only include line endings).
# - replace any backticks (`) with pipes (|) -- this makes parsing of the output easier.
# - replace "    |" with "|   |" -- makes the last-child prefix more consistent and easier to parse.
# - replace "|   " with "  " -- fixes whitespace to conform to Markdown conventions (spaces of two).
# - replace "|--" with "-" -- turns the item prefix into a hyphenated bullet point.
#
# At this point, the remaining lines are formatted to be ending like "- foo/bar/baz.md". The last command:
# - creates three matching groups, one for "foo/bar/baz.md", one for "foo/bar" and one for "baz.md".
# - replaces "- foo/bar/baz.md" with "- [baz.md](foo/bar/baz.md)".
# - replaces "- [baz.md](foo/bar/baz.md)" with "- [baz](foo/bar/baz.md)"
#
# Finally, `tail -n +2` removes the first two lines of the output (a newline and the "." for the root directory).
base_url="https://raw.githubusercontent.com/jorgegonzalez/rewst-tcg/main"

markdown=$(cd "$1" && tree -f --noreport -P "*.md|*.png" --charset ascii --sort=name . |
    sed \
      -e 's:.*/images$::g' \
      -e '/^$/d' \
      -e 's/`/|/g' \
      -e 's/    |/|   |/g' \
      -e 's/|   /  /g' \
      -e 's/|--/-/g' \
      -e 's:- \(\(.*\)/\(.*\)\):- [\3](\1):g' \
      -e 's/\.md]/]/g' |
    sed -r 's:\(\./:(/:g' | # Replace './' with '/' directly in paths
    awk -v url="$base_url" -F'\\]\\(' '{gsub(/ /, "%20", $2); print $1 "](" url $2}' |
    tail -n +2)


# The output is then returned with a trailing newline character.
printf "%s\n" "$markdown"
