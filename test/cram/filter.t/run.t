For reference, here is the nodes.dmp

  $ cat nodes.dmp
  2	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not kingdom	|
  3	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not species	|
  4	|	2	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	x	|
  5	|	2	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	x	|
  6	|	3	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not genus	|
  1	|	0	|	kingdom	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not species	|

==== FILTER BY RANK ====

The default is to filter by rank.

  $ printf "genus\n" > patterns.txt
  $ taxi filter nodes.dmp patterns.txt
  2	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not kingdom	|
  3	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not species	|

Select all rows with rank genus

  $ printf "genus\n" > patterns.txt
  $ taxi filter --column=3 nodes.dmp patterns.txt
  2	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not kingdom	|
  3	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not species	|

Select all rows with rank species

  $ printf "species\n" > patterns.txt
  $ taxi filter --column=3 nodes.dmp patterns.txt
  4	|	2	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	x	|
  5	|	2	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	x	|
  6	|	3	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not genus	|

Select all rows with rank kingdom

  $ printf "kingdom\n" > patterns.txt
  $ taxi filter --column=3 nodes.dmp patterns.txt
  1	|	0	|	kingdom	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not species	|

Multiple selections

  $ printf "species\ngenus\n" > patterns.txt
  $ taxi filter --column=3 nodes.dmp patterns.txt
  2	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not kingdom	|
  3	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not species	|
  4	|	2	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	x	|
  5	|	2	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	x	|
  6	|	3	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not genus	|

==== FILTER BY PARENT ID ==== 

Multiple selections

  $ printf "1\n3\n" > patterns.txt
  $ taxi filter --column=2 nodes.dmp patterns.txt
  2	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not kingdom	|
  3	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not species	|
  6	|	3	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not genus	|

==== FILTER BY ID ==== 

Multiple selections

  $ printf "2\n5\n4\n" > patterns.txt
  $ taxi filter --column=1 nodes.dmp patterns.txt
  2	|	1	|	genus	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	not kingdom	|
  4	|	2	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	x	|
  5	|	2	|	species	|	x	|	x	|	0	|	x	|	0	|	x	|	0	|	0	|	0	|	x	|

==== PATTERN NOT PRESENT ====

When pattern is not present then nothing is printed.

  $ printf "55\n66" > patterns.txt
  $ taxi filter --column=1 nodes.dmp patterns.txt
