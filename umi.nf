process extract_umis_from_pairs {

	cpus 1
	memory 4.GB

	input:
		tuple val(id), path(r1, stageAs:'in_r1.fq.gz'), path(r2, stageAs:'in_r2.fq.gz')
	output:
		tuple val(id), file('r1.fq.gz'), file('r2.fq.gz'), emit: umi_fastq 
	
	publishDir params.outDir, saveAs : {filename -> "01_extract_umis/${id}/${filename}"}

	container 'quay.io/biocontainers/umi_tools:1.1.2--py310h1425a21_1'

	script:
	"""
	umi_tools extract --extract-method=string --bc-pattern=NNNNNNNNNN --stdin=in_r2.fq.gz --read2-in=in_r1.fq.gz --stdout=r2.fq.gz --read2-out=r1.fq.gz -L extract.log
	"""
}

process fake_umi {

    input:
        tuple val(id), path(r1, stageAs:'in_r1.fq.gz'), path(r2, stageAs:'in_r2.fq.gz')
    output:
        tuple val(id), file('r1.fq.gz'), file('r2.fq.gz'), emit: umi_fastq 

    container 'quay.io/biocontainers/cutadapt:4.5--py39hf95cd2a_0'

	publishDir params.outDir, saveAs : {filename -> "01_extract_umis/${id}/${filename}"}

    script:

    """
    cutadapt \
    --rename '{id}_FAKEUMI' \
    -o r1.fq.gz -p r2.fq.gz \
    in_r1.fq.gz in_r2.fq.gz
    """
}
