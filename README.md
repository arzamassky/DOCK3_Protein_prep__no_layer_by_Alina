# DOCK3_Protein_prep__no_layer_by_Alina

Tutorial: Preparing a Protein and Running Blastermaster on Gimel2
0) What this setup does
Checks protein
Electrostatics: dielectric layer OFF (we pass an empty PDB for the layer).
Ligand desolvation: thin spheres ON.
Everything you need is in: /nfs/home/alina/new_scoring_pydock3_by_Alina
code: /nfs/home/alina/new_scoring_pydock3_by_Alina/pydock3 (patched blastermaster)
venv: /nfs/home/alina/new_scoring_pydock3_by_Alina/.venv
wrapper: /nfs/home/alina/new_scoring_pydock3_by_Alina/run_pydock3_nolayer.sh

1) Prepare your receptor PDB (Maestro)
Download PDB
From RCSB, download the PDB for your target.
Open & split
Maestro → File → Import Structures → choose your .pdb.
In Project Table: right-click → Split → Split into Separate Entries.
If splitting fails cleanly
Select → Residues → By Number/Sequence; select e.g., 1–300 → Create Subset for the receptor.
Merge receptor parts (if needed)
Select receptor entries → Project → Merge. Rename to e.g., Receptor_raw.
Delete unwanted components
Remove waters (HOH), ions (Na+, Cl−), extra chains, crystallization additives (Het groups you don’t want).
Protein Preparation Wizard
Tasks → Protein Preparation Wizard
Preprocess: assign bond orders, add hydrogens, delete waters >5 Å (default), fill missing side chains (Prime).
Review & Modify: check HIS protonation (HID/HIE/HIP), adjust Asp/Glu/Lys/Arg if needed.
Refine: minimize hydrogens/side chains (defaults OK).
Verify
View → Sequence Viewer to check numbering/chain integrity.
Remove remaining non-receptor parts.
Export
File → Export Structures → PDB, save as rec.pdb.
Tips
Histidines: confirm with local H-bonding network.
AltLocs: keep the biologically relevant one; delete others.
Important waters: if you plan to keep pocket waters, decide now.
Export hydrogens: either way is fine; the pipeline handles protonation.

2) Make a working directory & inputs (on Gimel)
Create a folder anywhere you have space, and put two files there:
rec.pdb — your prepped receptor
xtal-lig.pdb — a reference ligand near the binding site (used to define the box & spheres)
mkdir -p /path/to/my_target && cd /path/to/my_target
cp /wherever/rec.pdb .
cp /wherever/xtal-lig.pdb .


3) Use Alina’s runner (no extra installs)
(Optional) add a handy alias
# make ~/bin if it doesn't exist
mkdir -p ~/bin

# symlink the runner
ln -sf /nfs/home/alina/new_scoring_pydock3_by_Alina/run_pydock3_nolayer.sh ~/bin/pydock3_nolayer
chmod +x ~/bin/pydock3_nolayer
add ~/bin to your PATH (once):
# bash/sh users
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

Quick check:

which pydock3_nolayer
# should print: /nfs/home/alina/bin/pydock3_nolayer (or similar)

4) Create and run a Blastermaster job
A) Create the job scaffold
pydock3_nolayer blastermaster new --job_dir_path=bm_job
# (If you didn't make the alias, call the full path instead:)
# /nfs/home/alina/new_scoring_pydock3_by_Alina/run_pydock3_nolayer.sh blastermaster new --job_dir_path=bm_job

This creates bm_job/ with:
working/ (intermediates)
dockfiles/ (final grids)
blastermaster_config.yaml (pre-filled)
Defaults in this config (already set):
dock_files_generation:
  thin_spheres_elec:
    use: false   # dielectric layer OFF (electrostatics)
  thin_spheres_desolv:
    use: true    # thin spheres ON (desolvation)

B) Run
pydock3_nolayer blastermaster run --job_dir_path=bm_job

Key outputs (in bm_job/working/):
trim.electrostatics.phi + phi.size — electrostatics
vdw.vdw + vdw.bmp — VDW grids
ligand.desolv.hydrogen (and heavy) — desolvation
thin_spheres_desolv.* — desolvation thin spheres
receptor.crg.lowdielectric.pdb — receptor used for electrostatics
Copied to bm_job/dockfiles/: everything for docking + INDOCK.

5) Switching dielectric layer ON (if you want the old behavior)
Edit the job config before running:
vi bm_job/blastermaster_config.yaml

Set:
dock_files_generation:
  thin_spheres_elec:
    use: true

Then run:
pydock3_nolayer blastermaster run --job_dir_path=bm_job

(Desolvation thin spheres remain ON by default. To disable those too, set thin_spheres_desolv.use: false.)

6) Sanity checks
# Confirm flags:
grep -A2 'thin_spheres_elec:' bm_job/blastermaster_config.yaml
grep -A2 'thin_spheres_desolv:' bm_job/blastermaster_config.yaml

# Spot-check outputs:
ls -lh bm_job/working/{trim.electrostatics.phi,vdw.vdw,ligand.desolv.hydrogen}


7) Re-runs & new targets
Re-run same job cleanly:
rm -rf bm_job/{working,dockfiles,visualization}
pydock3_nolayer blastermaster run --job_dir_path=bm_job


New target:
mkdir -p /path/to/another && cd $_
cp /path/to/rec2.pdb rec.pdb
cp /path/to/lig2.pdb xtal-lig.pdb
pydock3_nolayer blastermaster new --job_dir_path=bm_job2
pydock3_nolayer blastermaster run --job_dir_path=bm_job2

8) Troubleshooting
showsphere/doshowsph.csh errors
The runner exports:
export DOCKBASE=/mnt/nfs/soft/dock/versions/dock385/DOCK3.8
export PATH="$DOCKBASE/bin:$PATH"
Use the provided runner so showsphere is found. Our pipeline no longer relies on /scratch/... temp scripts.
“File … does not exist” at the end
Usually means a prior step failed. Check the per-step subfolders in bm_job/working/ for a log file and errors (e.g., in spheres_to_p_d_b_conversion_step_outfiles=*).
Wrong input files used
new copies rec.pdb and xtal-lig.pdb from your current directory. Make sure you’re in the right folder before running new.
if pydock3_nolayer isn’t found: your PATH didn’t load; re-source ~/.bashrc (or log out/in).
if a job errors about showsphere/doshowsph.csh in a log: harmless in this setup; the dielectric layer for electrostatics is disabled and our code bypasses that path.
don’t pip install into Alina’s shared venv; if you need extras, use your own venv.

Appendix (optional): Amber protonation on Wynton
Not required for this pipeline — pydock3 performs protonation internally.
Keep this only if you specifically need an Amber-protonated rec.crg.pdb for other workflows.
On Wynton:
# use dev1 or dev2
source /wynton/home/shoichetlab/alina/amber16/amber_fixed.sh

tleap
# In LEaP:
#   source leaprc.protein.ff14SB
#   a = loadpdb rec.pdb
#   check a
#   saveAmberParm a a.prmtop a.inpcrd
#   quit

amber.python /wynton/home/shoichetlab/Alina/Scripts/generate_rec_crg.py
# produces rec.crg.pdb

Then copy rec.crg.pdb wherever you need it. (Again: blastermaster here does not require it.)
