nextflow.enable.dsl=2

process align {

	cpus 1


        input:
                tuple( val(id), path('reads.fq.gz'), path('wt.fa'), path('donor.fa') )
        output:
                tuple val(id), path('out.csv.gz'), emit: alignments

        publishDir params.outDir, saveAs : {filename -> "04_align/${id}/${filename}"}, mode: 'copy'

        container "${params.parasail_container}"

        script:

        """
        cat << EOF > params.yml
        wt: wt.fa
        reference: donor.fa
        fastq:
            merged: reads.fq.gz
        EOF
        global_align.py params.yml reads.fq.gz
        """
}
