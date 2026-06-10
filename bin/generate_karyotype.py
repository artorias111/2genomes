#!/usr/bin/env python3
"""
Generate a Circos karyotype file for two chromosome-level genomes.

Ref chromosomes are assigned distinct colors (chr1, chr2, …) in the order
they appear in the .fai index.  Query chromosomes are colored to match their
most homologous ref chromosome, determined by summing total aligned bases from
the MashMap output.  If a ref chromosome was split into multiple query
scaffolds, every fragment gets the same color as the ref parent — the user
can visually judge which is the major vs minor piece from the link density.
Unanchored query chromosomes (no MashMap hit) are colored grey.
"""

import argparse
import sys
from collections import defaultdict

# 50 visually distinct, muted colors — cycles if genome has > 50 chromosomes
_PALETTE = [
    "163,80,80",    "80,110,163",   "110,135,110",  "195,155,80",
    "115,90,140",   "85,140,140",   "185,110,95",   "70,85,115",
    "145,160,120",  "180,120,80",   "100,100,125",  "130,150,150",
    "180,100,100",  "100,125,150",  "120,145,100",  "210,180,100",
    "140,110,130",  "110,155,155",  "140,70,70",    "60,95,130",
    "90,115,80",    "170,140,100",  "110,90,110",   "95,130,120",
    "200,130,130",  "120,160,195",  "155,185,135",  "220,190,110",
    "155,125,165",  "95,165,165",   "160,110,85",   "75,140,100",
    "195,145,120",  "90,115,150",   "130,155,115",  "205,170,90",
    "130,100,120",  "100,145,145",  "155,85,85",    "70,100,140",
    "105,130,90",   "185,155,95",   "125,105,145",  "90,150,150",
    "145,95,75",    "80,110,145",   "115,140,100",  "200,165,95",
    "120,95,115",   "85,135,115",
]


def color_name(index):
    """Return the circos color alias for position index (0-based)."""
    return f"chr{(index % len(_PALETTE)) + 1}"


def parse_mashmap(mashmap_file):
    """
    Return {query_chrom: best_ref_chrom} based on maximum total aligned bases.
    MashMap columns: qname qlen qstart qend strand rname rlen rstart rend identity
    """
    coverage = defaultdict(lambda: defaultdict(int))
    with open(mashmap_file) as fh:
        for line in fh:
            cols = line.split()
            if len(cols) < 9:
                continue
            qname  = cols[0]
            qstart = int(cols[2])
            qend   = int(cols[3])
            rname  = cols[5]
            coverage[qname][rname] += qend - qstart

    return {qname: max(hits, key=hits.get)
            for qname, hits in coverage.items()}


def read_fai(fai_path):
    """Return list of (chrom_name, length_str) from a .fai file."""
    entries = []
    with open(fai_path) as fh:
        for line in fh:
            cols = line.strip().split('\t')
            if cols:
                entries.append((cols[0], cols[1]))
    return entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ref_index',    required=True)
    parser.add_argument('--query_index',  required=True)
    parser.add_argument('--ref_prefix',   required=True)
    parser.add_argument('--query_prefix', required=True)
    parser.add_argument('--mashmap',      required=False,
                        help="MashMap output used to determine homologous coloring")
    args = parser.parse_args()

    ref_chroms   = read_fai(args.ref_index)
    query_chroms = read_fai(args.query_index)

    # Assign a color to each ref chromosome by position
    ref_color = {name: color_name(i) for i, (name, _) in enumerate(ref_chroms)}

    # Print ref karyotype
    for name, length in ref_chroms:
        cid = f"{args.ref_prefix}_{name}"
        print(f"chr - {cid} {name} 0 {length} {ref_color[name]}")

    # Determine dominant ref chrom for each query chrom
    dominant = parse_mashmap(args.mashmap) if args.mashmap else {}

    # Sort query chroms in DESCENDING order of their homologous ref index so that
    # after the large gap (last-ref → first-query) the query block runs from the
    # homolog of the last ref down to the homolog of the first ref.  This places
    # homolog pairs adjacent at the top gap (last-query → first-ref) and keeps
    # link lines from crossing each other.
    ref_order = {name: i for i, (name, _) in enumerate(ref_chroms)}

    def query_sort_key(item):
        name, _ = item
        dref = dominant.get(name)
        return -ref_order.get(dref, -1) if dref else len(ref_chroms)

    sorted_query = sorted(query_chroms, key=query_sort_key)

    for name, length in sorted_query:
        cid   = f"{args.query_prefix}_{name}"
        dref  = dominant.get(name)
        color = ref_color.get(dref, "grey") if dref else "grey"
        print(f"chr - {cid} {name} 0 {length} {color}")

    print("karyotype.txt written to stdout.", file=sys.stderr)


if __name__ == "__main__":
    main()
