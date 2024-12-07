# Info

To create the smaller nodes.dmp file for the test:

- First, run both the OCaml and the C++ program with the given IDs on the full nodes.dmp file.
  - Ensure those match (e.g., `diff <(cut -f2 ocaml_output.tsv | sort | uniq) <(cat test/cram/descendants.t/reference_output.txt | sort | uniq)`)
- Then use `grep` to pull out any lines in the nodes.dmp file that contain those IDs.
  - E.g., `grep -w -f expected_ids.txt nodes.dmp > nodes_sample.dmp`
- Then add in some random lines from the original file.
  - We don't care if we "break" the original graph up in weird ways in the test file, since only the graphs descending from the target IDs need to be intact and correct for this test.
  - E.g., `shuf nodes.dmp | head -n1000 >> nodes_sample.dmp`
- Dereplicate and shuffle the sample file, just in case any of the original lines were sampled.
  - `sort nodes_sample.dmp | uniq | shuf > z && mv z nodes_sample.dmp`
- Finally, rename the file:
  - `mv nodes_sample.dmp nodes.dmp`

Here it all is for reference.

```
grep -w -f expected_ids.txt nodes.dmp > nodes_sample.dmp
shuf nodes.dmp | head -n1000 >> nodes_sample.dmp
sort nodes_sample.dmp | uniq | shuf > z && mv z nodes_sample.dmp
mv nodes_sample.dmp nodes.dmp
```
