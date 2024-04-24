nextflow.enable.dsl=2

process vsearch {

	cpus 1
	container 'quay.io/biocontainers/vsearch:2.22.1--hf1761c0_0'

        input:
                tuple( val(id), file('read1.fq.gz'), file('read2.fq.gz') ) 
        output:
                tuple val(id), file('*.fq.gz'), emit: merged_fastq

        publishDir params.outDir, saveAs : {filename -> "03_vsearch/${id}/${filename}"}

        script:

        """
        vsearch \
                --fastq_mergepairs read1.fq.gz \
                --reverse read2.fq.gz \
                --fastq_allowmergestagger \
                --fastq_maxns 0 \
                --fastq_maxdiffs 0 \
                --fastqout ${id}.fq &&
        gzip -f ${id}.fq
        """
}
