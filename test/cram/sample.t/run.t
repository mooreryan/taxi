Unzip nodes file

  $ gunzip -c nodes.dmp.gz > nodes.dmp

When sample size is greater than the number of nodes for a given rank, 
return all of them.

  $ taxi sample nodes.dmp genus 10 | sort > genus_sample.txt
  $ grep -w genus nodes.dmp | awk 'BEGIN{FS="\t"} {print $1}' | sort > all_genus.txt
  $ diff all_genus.txt genus_sample.txt

  $ taxi sample nodes.dmp species 100 | sort > species_sample.txt
  $ grep -w species nodes.dmp | awk 'BEGIN{FS="\t"} {print $1}'| sort > all_species.txt
  $ diff all_species.txt species_sample.txt

Output is the correct size

  $ taxi sample nodes.dmp genus 5 > genus.txt
  $ awk 'END {print NR}' genus.txt
  5
  $ taxi sample nodes.dmp species 50 > species.txt
  $ awk 'END {print NR}' species.txt
  50

Outputs contain no duplicates

  $ sort genus.txt | uniq | awk 'END {print NR}'
  5
  $ sort species.txt | uniq | awk 'END {print NR}'
  50

Output is a subset of all data (no output means no lines unique to first file)

  $ sort genus.txt > genus_sorted.txt
  $ comm -23 genus_sorted.txt all_genus.txt
  $ sort species.txt > species_sorted.txt
  $ comm -23 species_sorted.txt all_species.txt
