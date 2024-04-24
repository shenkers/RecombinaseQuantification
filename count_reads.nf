nextflow.enable.dsl=2

process count_reads {

	cpus 1
    container 'ubuntu'

        input:
                tuple( val(id), path('reads.fq.gz'), val(step) )
        output:
                tuple( val(id), val(step), path('count.csv'), emit: read_count )

        publishDir params.outDir, saveAs : {filename -> "00_count/${id}/${step}_${filename}"}, mode: 'copy'

        script:

        """
        count=\$( zcat reads.fq.gz | wc -l )
        count=\$((count/4))

        cat << EOF > count.csv
        id,step,count
        $id,$step,\$count
        EOF
        """
}
