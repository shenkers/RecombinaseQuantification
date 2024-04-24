# RecombinaseQuantification

# Docker Images

Change to the "docker" directory and run

```
NAMESPACE=something docker compose build
```

This will build the docker two docker containers:

- [NAMESPACE]-r : Used to knit the R-markdown report
- [NAMESPACE]-parasail : Used to perform sequence alignments

If you are running this workflow on the cloud or a compute cluster you will want to distribute these images to a container registry.

# Running the Workflow

To run the workflow you must construct a samplesheet CSV describing the samples and how they should be analyzed. An example samplesheet is provided (here)[example_config/example_samplesheet.csv].

The "wt" and "insert" sequences are provided as FASTA files. The FASTA sequence should contain only the portion of the amplified DNA between the forward and reverse primers.

The workflow can be run with the following command:

```
nextflow run main.nf \
    --samplesheet example_config/example_samplesheet.csv \
    --outDir out_test_run
```
