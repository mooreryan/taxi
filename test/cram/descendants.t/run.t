--help doesn't fail

  $ taxi descendants --help 1>/dev/null

Gives expected output

  $ gunzip -c nodes.dmp.gz > nodes.dmp
  $ gunzip -c expected_ids.txt.gz > expected_ids.txt
  $ taxi descendants nodes.dmp ids.txt 1> result.tsv 2> err
  $ cat result.tsv | awk 'BEGIN {FS="\t"} {print $3}' | sort > actual_ids.txt
  $ diff actual_ids.txt expected_ids.txt
