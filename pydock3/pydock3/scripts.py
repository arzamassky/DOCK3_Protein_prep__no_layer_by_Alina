from fire import Fire
from pydock3.blastermaster.blastermaster import Blastermaster

def main():
    # Expose class methods as subcommands, e.g.:
    #   python -m pydock3.scripts blastermaster new --job_dir_path=...
    #   python -m pydock3.scripts blastermaster run --job_dir_path=...
    Fire({"blastermaster": Blastermaster})

if __name__ == "__main__":
    main()
