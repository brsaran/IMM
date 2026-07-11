# IMM — Integrated MHC/B-cell Epitope Mapper for T–B Reciprocity

IMM is a Perl-based pipeline that scans a protein sequence and predicts **T-B cell epitope "reciprocity"** — regions where MHC class I (T-cell, CD8+), MHC class II (T-cell, CD4+) and B-cell epitope predictions overlap or sit adjacent to one another along the same stretch of sequence. It does this by orchestrating **nine external immune-prediction tools**, parsing their outputs, and combining the individual predictions into a single confidence call per position using a **fuzzy logic inference system** (built in Octave).

The output highlights 33-residue windows of the input protein where T-cell and B-cell epitopes co-occur in different orders (MHC‑I → MHC‑II → B-cell, B-cell → MHC‑I → MHC‑II, etc.), which is useful for identifying regions likely to drive both cellular and humoral immune responses — e.g. for vaccine/epitope design.

> ⚠️ IMM is a **pipeline/wrapper**, not a standalone predictor. It does not include the third-party tools themselves — you must install each one separately and point IMM to them via the `path` configuration file (see below).

---

## 1. How it works (pipeline overview)

Running `IMM` on a FASTA file executes the following stages in order (see the main `IMM` script):

1. **Parse input** (`bin/Fparse.pl`) — reads the FASTA file and slides a window across the sequence to generate all overlapping 9-mers (for MHC‑I / B-cell tools) and 12-mers (for MHC‑II / LBEEP).
2. **BLAST self-similarity check** (`bin/blast.pl`) — BLASTs every 9-mer/12-mer against a prebuilt human proteome database (`blast_bin/HUMAN*`) to flag peptides with high similarity to self-proteins.
3. **MHC-I binding predictions** — run in sequence:
   - MHCflurry (`bin/mhcflurry.pl`)
   - MHCSeqNet (`bin/mhcseqnet.pl`)
   - NetMHCpan (`bin/netmhci.pl`)
4. **MHC-II binding predictions**:
   - MixMHC2pred (`bin/MixMHC2.pl`)
   - NetMHCIIpan (`bin/netmhcii.pl`)
5. **Other T-cell metrics**:
   - NetCTLpan (`bin/netctlpan.pl`) — combines MHC-I binding, proteasomal cleavage and TAP transport efficiency.
   - NetTepi (`bin/nettepi.pl`) — T-cell epitope immunogenicity/propensity.
6. **B-cell epitope predictions**:
   - LBEEP (`bin/lbeep.pl`) — linear B-cell epitope prediction.
   - Epidope (`bin/epidope.pl`) — deep-learning B-cell epitope prediction.
7. **Result parsing**:
   - `bin/mhc1parse.pl` — consolidates all MHC-I-related tool outputs.
   - `bin/mhc2parse.pl` — consolidates all MHC-II-related tool outputs.
   - `bin/bcellparse.pl` — consolidates B-cell tool outputs.
   - Each of these parse steps calls the **Octave fuzzy-logic engine** (`bin/fuzzy.pl` → `bin/fuzzy.m`, using the rule base in `bin/octaveepi.fis`) to combine multiple raw prediction scores into a single High/Moderate/Low call per peptide.
8. **Final scoring** (`bin/scorer.pl`) — aligns the MHC-I, MHC-II and B-cell calls along the protein sequence and reports, for every position, the 6 possible orderings of a 33-residue T-B-reciprocity window (`M1-M2-B`, `M1-B-M2`, `M2-B-M1`, `M2-M1-B`, `B-M2-M1`, `B-M1-M2`), producing `result.csv` and a colour-coded `result.html`.
9. Results are moved from the working `temp/` folder into `results/<Jobname>/`, where `<Jobname>` is taken from the FASTA header.

Optionally, IEDB's **Population Coverage** tool (`bin/iedbpop.pl`, `bin/iedbpop2.pl`) can be run on the identified MHC-I/MHC-II binders to estimate population coverage.

---

## 2. Repository structure

```
IMM/
├── IMM                    # Main pipeline driver (Perl) — run this on a single FASTA file
├── bulk.pl                # Batch driver — runs IMM on every sequence in a multi-FASTA-style list
├── path                   # Configuration file: paths & conda environments for every external tool
├── mhc1alleles.txt        # HLA class I alleles used for MHCflurry / MHCSeqNet
├── mhc1nettepi.txt        # HLA class I alleles used for NetTepi
├── mhc2alleles.txt        # HLA class II alleles used for MixMHC2pred
├── mhc2allelesnet.txt     # HLA class II alleles used for NetMHCIIpan
├── bin/                   # All pipeline scripts (Perl) + Octave helper scripts
│   ├── Fparse.pl          # FASTA parsing / k-mer generation
│   ├── blast.pl           # BLAST self-similarity screening
│   ├── mhcflurry.pl, mhcseqnet.pl, netmhci.pl      # MHC-I tools
│   ├── MixMHC2.pl, netmhcii.pl                     # MHC-II tools
│   ├── netctlpan.pl, nettepi.pl                    # Other T-cell tools
│   ├── lbeep.pl, epidope.pl                        # B-cell tools
│   ├── mhc1parse.pl, mhc2parse.pl, bcellparse.pl   # Per-category result consolidation + fuzzy scoring
│   ├── scorer.pl                                   # Final T-B reciprocity scoring/report
│   ├── iedbpop.pl, iedbpop2.pl                     # IEDB population coverage (MHC-I / MHC-II)
│   ├── fuzzy.pl, fuzzy.m, fuzzpkg.m                # Octave fuzzy-inference wrapper scripts
│   └── octaveepi.fis                               # Fuzzy inference system rule/membership file (Octave)
├── blast_bin/              # Prebuilt BLAST protein database of the human proteome (HUMAN.*)
├── Fuzzy/                  # Supporting fuzzy-logic development/test files (FIS files, test scripts)
└── All_results/            # Sample/archived output runs (not covered by this README)
```

---

## 3. External tools used

IMM itself is glue code — all of the actual predictions come from the following third-party tools, which you must install/obtain separately and license according to each provider's terms:

| Category | Tool | Purpose |
|---|---|---|
| Sequence similarity | **BLAST+ (blastp)** | Screens candidate peptides against the human proteome for self-similarity |
| MHC-I binding | **MHCflurry** | MHC class I peptide-binding affinity prediction |
| MHC-I binding | **MHCSeqNet** | Deep-learning MHC class I binding prediction |
| MHC-I binding | **NetMHCpan** (4.1) | MHC class I binding prediction (DTU Health Tech) |
| MHC-II binding | **MixMHC2pred** | MHC class II binding prediction |
| MHC-II binding | **NetMHCIIpan** (4.1) | MHC class II binding prediction (DTU Health Tech) |
| T-cell epitope features | **NetCTLpan** (1.1) | Integrated CTL epitope prediction (binding + cleavage + TAP) |
| T-cell immunogenicity | **NetTepi** (1.0) | T-cell epitope propensity/immunogenicity (requires Python 2.7) |
| B-cell epitope | **LBEEP** ([source](https://github.com/brsaran/LBEEP/)) | Linear B-cell epitope prediction |
| B-cell epitope | **Epidope** | Deep-learning B-cell epitope prediction |
| Population coverage | **IEDB Population Coverage Tool** | Estimates population coverage of predicted binders |
| Score fusion | **GNU Octave** + **fuzzy-logic-toolkit** package | Combines multiple raw tool scores into a single fuzzy (Low/Moderate/High) call |

---

## 4. Prerequisites

- **Linux** environment (the scripts shell out to Unix commands such as `mkdir`, `mv`, `cp`, `pwd`).
- **Perl** (no non-core modules are required — the scripts only use core Perl).
- **Conda or Mamba** — most tools above are expected to run either from a direct install path or inside a named conda/mamba environment (IMM supports both, see §5).
- **GNU Octave**, run from its own conda environment, with the **`fuzzy-logic-toolkit`** package installed (`pkg install fuzzy-logic-toolkit` inside Octave). IMM checks for this package automatically before running fuzzy scoring.
- **BLAST+** (`blastp`) — either on `PATH`/a given install directory, or inside a conda environment.
- Each of MHCflurry, MHCSeqNet, NetMHCpan, MixMHC2pred, NetMHCIIpan, NetCTLpan, NetTepi, LBEEP (available at [github.com/brsaran/LBEEP](https://github.com/brsaran/LBEEP/)), Epidope, and the IEDB Population Coverage tool must be **installed/downloaded separately** by the user (several, such as the NetMHC family and NetCTLpan, require an academic license from DTU Health Tech). NetTepi specifically requires a **Python 2.7** environment.

---

## 5. Configuration — the `path` file

Before running IMM, open the `path` file at the repository root and edit it to match your local installation. For each tool there are two lines:

```
<toolkey>=<install_or_binary_directory>
conda_env=<conda_environment_name_or_NONE>
```

Rules:
- If a tool's binary is available inside a **named conda/mamba environment**, set `conda_env=<env_name>` — IMM will run it via `conda run -n <env_name> ...`.
- If a tool is **not** run from a conda environment, set `conda_env=NONE` and make sure the directory path is filled in.
- Some tools' path is *only* required if they are **not** in a conda environment (e.g. `mhcflurry`, `blast`); for others the path is **mandatory regardless** of conda usage (e.g. `mhcseqnet`, `netmhcpani`, `nettepi`, `netctlpan`, `mixmhc2`, `netmhcpanii`, `lbeep`, `IEDBpop`) — see the comments already present in the `path` file for each entry.
- `octave`'s path is always left as `NONE`; only its `conda_env` needs to be set, and that environment must have `fuzzy-logic-toolkit` installed.
- **LBEEP** can be obtained from [github.com/brsaran/LBEEP](https://github.com/brsaran/LBEEP/). In addition to setting its path here, you must also edit the `LBEEP4IMM` file inside your LBEEP installation to point to the LBEEP executable — see that repository's own README for details.
- For **NetTepi**, point `conda_env` at an environment running Python 2.7.

| Key in `path` | Tool | Path mandatory? |
|---|---|---|
| `mhcflurry` | MHCflurry | Only if not in a conda env |
| `mhcseqnet` | MHCSeqNet | Always |
| `netmhcpani` | NetMHCpan (MHC-I) | Always |
| `nettepi` | NetTepi | Always (needs Python 2.7 conda env) |
| `netctlpan` | NetCTLpan | Always |
| `blast` | BLAST+ | Only if not in a conda env |
| `mixmhc2` | MixMHC2pred | Always |
| `netmhcpanii` | NetMHCIIpan (MHC-II) | Always |
| `lbeep` | LBEEP | Always (also edit `LBEEP4IMM` inside the LBEEP package) |
| `epidope` | Epidope | Not mandatory (leave `NONE`); conda env mandatory |
| `IEDBpop` | IEDB Population Coverage | Always; conda env optional |
| `octave` | GNU Octave | Always `NONE`; conda env mandatory (must have `fuzzy-logic-toolkit`) |

### Allele lists
Edit these plain-text files to control which HLA alleles are queried:
- `mhc1alleles.txt` — HLA class I alleles for MHCflurry/MHCSeqNet (format: `HLA-A*02:01`)
- `mhc1nettepi.txt` — HLA class I alleles for NetTepi (format: `HLA-A02:01`)
- `mhc2alleles.txt` — HLA class II alleles for MixMHC2pred (format: `DRB1_03_01`)
- `mhc2allelesnet.txt` — HLA class II alleles for NetMHCIIpan (format: `DRB1_0301`)

---

## 6. Usage

### Single sequence
```bash
perl IMM my_protein.fasta
```
- The input file should be a standard single-sequence FASTA file.
- IMM creates a working `temp/` directory, runs the full pipeline described in §1, and on success moves the results to `results/<Jobname>/`, where `<Jobname>` is derived from the first 12 characters of the FASTA header line.
- Progress/status for each stage (BLAST, MHCflurry, NetMHCpan, etc.) is printed to the console; errors and warnings are logged to `temp/errlog`.

### Batch mode
```bash
perl bulk.pl
```
- Reads a file named `geneSrt` in the working directory, expected to contain sequences in pairs of lines (header line, then sequence line) — i.e. a simplified multi-FASTA layout.
- Runs `perl IMM` once per sequence, appending progress to `log.out` and errors to `error.log`.
- Use this when you need to process many proteins/genes in one go.

---

## 7. Input / output

**Input:** a plain FASTA file with a header line (`>SequenceName`) followed by the protein sequence.

**Output** (written to `results/<Jobname>/` after a run):
- `result.csv` — tabular results. Each row corresponds to a starting position in the protein and reports the fuzzy-combined call (e.g. `H`/`L` for High/Low confidence) for the 6 possible orderings of a 33-residue MHC-I / MHC-II / B-cell epitope window: `M1-M2-B`, `M1-B-M2`, `M2-B-M1`, `M2-M1-B`, `B-M2-M1`, `B-M1-M2`, along with the residue ranges each segment corresponds to.
- `result.html` — the same results rendered as a colour-coded HTML table:
  - **Green** background — two or more segments called "High".
  - **Yellow** background — a mix of at least one "Moderate"/"High" call.
  - **White** background — low-confidence window.
- Intermediate per-tool outputs (BLAST hits, MHCflurry/NetMHCpan/NetMHCIIpan/MixMHC2/NetCTLpan/NetTepi/LBEEP/Epidope raw predictions, and consolidated `mhcifull.csv` / `mhciifull.csv` / `bcellfull.csv`) are also kept in the results folder for inspection/debugging.

---

## 8. Notes on the fuzzy logic component

Score fusion across tools is handled by an Octave fuzzy inference system:
- `bin/fuzzy.pl` calls Octave (`conda run -n OCTAVE octave bin/fuzzy.m ...`).
- `bin/fuzzy.m` loads the `fuzzy-logic-toolkit` package and evaluates input scores against the rule/membership base defined in `bin/octaveepi.fis`, using `evalfis`.
- The `Fuzzy/` folder contains supporting FIS files and test scripts used during development of this rule base.

This README does not document or modify the specific fuzzy rules/membership functions themselves — if you need to tune them, refer directly to `bin/octaveepi.fis` and the files in `Fuzzy/` with an Octave fuzzy-logic reference.

---

## 9. Troubleshooting tips

- If a stage exits with `Path for <Tool> is not set!`, double-check the corresponding entry in `path`.
- If you see `Environment <name> does not exist!`, the conda/mamba environment named in `path` isn't available — create it or fix the name.
- If MHC-I/II or fuzzy scoring fails with `Fuzzy-logic-toolkit is not installed`, install it inside your Octave conda environment: run `octave --eval "pkg install -forge fuzzy-logic-toolkit"` (or install from source) inside that environment.
- Check `temp/errlog` (or `error.log` in batch mode) for the specific external-tool error when a stage fails.

---

## License

This project is licensed under the **MIT License**. You are free to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of this software, provided that the original copyright notice and this permission notice are retained. See the [LICENSE](LICENSE) file for the full text.

Copyright (c) 2026 Saravanan V and the Indian Council of Medical Research (ICMR)
