# Asciinema Demo Recordings

Pre-scripted `.cast` files are included for embedding in the presentation.
To record **real** demos on the ilifu cluster:

## Prerequisites

```bash
pip install asciinema
```

## Recording

SSH into the cluster and navigate to the tutorial directory:

```bash
ssh -A <username>@slurm.ilifu.ac.za
cd ~/tutorial2
```

Then run the recording helper:

```bash
# Record basic demo (minimal.sbatch submission)
bash presentation/demos/record.sh basic

# Record advanced demo (maximal.sbatch + containers)
bash presentation/demos/record.sh advanced

# Record both
bash presentation/demos/record.sh all
```

## Playback

```bash
# Local playback
asciinema play presentation/demos/demo_basic.cast

# Or open presentation/index.html — the player is embedded
```

## Tips

- Keep recordings under 30 seconds for the presentation
- Use `--speed 1.5` during playback to keep pace up
- The presentation player auto-plays and loops
