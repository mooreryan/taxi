## Take a small nodes sample.

```
shuf ../nodes.dmp | head -n100 > nodes.dmp

```

## Overview of rank counts

```
ruby -e 'h=Hash.new(0); ARGF.each { |l|  rank=l.split("\t|\t")[2]; h[rank]+=1 }; h.sort_by{ |_, v| v }.each{ |k,v| puts "#{k} #{v}" }' nodes.dmp
subfamily 1
subspecies 1
strain 2
genus 5
no rank 6
species 85
```

## Get some "expected" files

```
grep -w genus nodes.dmp | cut -f1 -d$'\t' | sort > all_genus.txt
grep -w species nodes.dmp | cut -f1 -d$'\t' | sort > all_species.txt
```
