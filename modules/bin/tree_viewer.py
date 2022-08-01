#!/usr/bin/env python3
import sys
from ete3 import PhyloTree, TreeStyle

PROGRAM = "tree_viewer"
VERSION = "1"


def tree_viewer(newick):
    #alg = "Sample_1/Sample_1_multiple_alignments_by_muscle.afa"

    t = PhyloTree(newick)   
    #print(t)
    tree = t.render("phylotree.png", w=750)
    return(tree)

if __name__ == '__main__':
    import argparse as ap
    import os
 
    parser = ap.ArgumentParser(
        prog=PROGRAM,
        conflict_handler='resolve',
        description=(
            f'{PROGRAM} (v{VERSION}) - Visualize a phylogenetic tree from newick file.'
        )
    )

    parser.add_argument('--nw', metavar="STR", type=str, help='A file to visualize the tree in NEWICK format.')
#    parser.add_argument('--alg', metavar="STR", type=str, help='multiple alignement file in FASTA format.')


    if len(sys.argv) == 2:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()
    error = 0

    if len(sys.argv) == 3:
        tree_viewer(args.nw)


sys.exit(error)
