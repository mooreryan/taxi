--help doesn't fail

  $ taxi descendants --help 1>/dev/null

FULL OUTPUT
===========

Gives expected ids (checked against the original program)

  $ gunzip -c nodes.dmp.gz > nodes.dmp
  $ gunzip -c expected_ids.txt.gz | sort | uniq > expected_ids.txt
  $ taxi descendants --full-output nodes.dmp ids.txt 1> result_full.tsv 2> err

The 2nd column of the output will be each node present in all graphs.

  $ cat result_full.tsv | awk 'BEGIN {FS="\t"} {print $2}' | sort | uniq > actual_ids.txt
  $ diff actual_ids.txt expected_ids.txt

The 1st column should have the IDs that are actual present in the nodes file.

  $ grep -w 377315 actual_ids.txt
  377315
  $ grep -w 561 actual_ids.txt
  561
  $ grep -w 374923 actual_ids.txt
  374923

And it should NOT have the ID that is NOT present in the nodes file.

  $ grep -w 2100000000 actual_ids.txt
  [1]

BASIC OUTPUT
============

Basic output (2-column output)

  $ taxi descendants nodes.dmp ids.txt 1> result_basic.tsv 2> err

The 2nd column of the output will be each node present in all graphs.

  $ cat result_basic.tsv | awk 'BEGIN {FS="\t"} {print $2}' | sort | uniq > actual_ids.txt
  $ diff actual_ids.txt expected_ids.txt

The 1st column should have the IDs that are actual present in the nodes file.

  $ grep -w 377315 actual_ids.txt
  377315
  $ grep -w 561 actual_ids.txt
  561
  $ grep -w 374923 actual_ids.txt
  374923

And it should NOT have the ID that is NOT present in the nodes file.

  $ grep -w 2100000000 actual_ids.txt
  [1]

COMPARE BOTH
============

  $ wc -l result*.tsv
    4868 result_basic.tsv
    9622 result_full.tsv
   14490 total


Gives the expected output (checked against XXXX.X.X) TODO add back in when you cut a new release

$ gunzip -c expected_output.tsv.gz | sort > expected_output.tsv
$ taxi descendants nodes.dmp ids.txt | sort > result.tsv
$ diff expected_output.tsv result.tsv
