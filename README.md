# RecombinaseQuantification

## Prerequisites

To run this workflow you will need to have nextflow and docker installed.

## Docker Images

Change to the "docker" directory and run

```
NAMESPACE=something docker compose build
```

This will build the docker two docker containers:

- [NAMESPACE]-r : Used to knit the R-markdown report
- [NAMESPACE]-parasail : Used to perform sequence alignments

If you are running this workflow on the cloud or a compute cluster you will want to distribute these images to a container registry.

Once the docker images are ready, edit the `params.r_container` and `params.parasail_container` values in (nextflow.config)[nextflow.config] to point to the namespaced image IDs.

## Running the Workflow

To run the workflow you must construct a samplesheet CSV describing the samples and how they should be analyzed. An example samplesheet is provided [here](example_config/example_samplesheet.csv).

The "wt" and "insert" sequences are provided as FASTA files. The FASTA sequence should contain only the portion of the amplified DNA between the forward and reverse primers.

The workflow can be run with the following command:

```
nextflow run main.nf \
    --samplesheet example_config/example_samplesheet.csv \
    --outDir out_test_run
```

## Output

Final and intermediate outputs of running the workflow will be written to the location specified by the `--outDir` parameter. These include:

- preprocessing_stats.csv : The number of reads at each stage of data processing, aggregated across all samples
- mismatched_event_frequency_summary.csv : The number of WT/INSERT/OTHER reads, allowing up to 2 mismatches, aggregated across all samples
- 00_count : per-sample tabulation of read counts
- 01_extract_umis : per-sample output from UMI extraction (if performed)
- 02_cutadapt : per-sample result of adapter trimming
- 03_vsearch : per-sample result of paired-end read merging
- 04_align : per-sample tables of read alignments vs WT and INSERT sequences
- 05_report : per-sample reports listing the most-frequently observed sequences
