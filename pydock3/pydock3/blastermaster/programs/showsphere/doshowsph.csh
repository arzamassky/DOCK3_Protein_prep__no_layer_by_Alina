#!/bin/csh -f
# usage: doshowsph.csh in.sph cluster out.pdb
if ( $#argv != 3 ) then
  echo "Usage: $0 spheres.sph cluster out.pdb"
  exit 1
endif
set in  = "$1"
set cl  = "$2"
set out = "$3"
showsphere -label S "$in" "$cl" > "$out"
