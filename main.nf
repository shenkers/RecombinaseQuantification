nextflow.enable.dsl=2

params.outDir = 'out'

include {extract_umis_from_pairs; fake_umi} from './umi'
include {trim_primers} from './cutadapt'
include {vsearch} from './vsearch'
include {align} from './align'
include {count_reads} from './count_reads'
include {editing_summary} from './report'

samplesheet = Channel
    .fromPath(params.samplesheet)

parsedSamplesheet = samplesheet
    .splitCsv(header:['id','read1','read2','wt','donor','forward_primer','reverse_primer','umi'],skip:1)

by_umi = parsedSamplesheet.branch{
    has_umi: it.umi != '' && it.umi != 'NA'
        return it
    no_umi: !( it.umi != '' && it.umi != 'NA' )
        return it
}

no_umi_data = by_umi.no_umi.map { tuple it.id, it.read1, it.read2 }

data = by_umi.has_umi
    .map { tuple it.id, it.read1, it.read2 }

primers = parsedSamplesheet
    .map { tuple it.id, it.forward_primer, it.reverse_primer }

sequences = parsedSamplesheet.map { tuple it.id, it.wt, it.donor }

report_rmd = file('editing_summary.Rmd')

workflow {

    extract_umis_from_pairs(data)
    fake_umi( no_umi_data )
    to_trim = extract_umis_from_pairs.out.umi_fastq.mix( fake_umi.out.umi_fastq )
    trim_primers(to_trim.combine(primers, by: 0))
    vsearch(trim_primers.out.trimmed_fastq)
    align(vsearch.out.merged_fastq.combine(sequences, by: 0))

    to_count = data.mix(no_umi_data).map{ id, r1, r2 -> [ id, r1, 'RAW' ] }.mix(
        trim_primers.out.trimmed_fastq.map{ id, r1, r2 -> [ id, r1, 'TRIM' ] },
        vsearch.out.merged_fastq.map{ id, fastq -> [ id, fastq, 'MERGE' ] }
    )

    count_reads(to_count)
    count_reads.out.read_count.map{ id, step, tbl -> tbl }.collectFile(name: "preprocessing_stats.csv", keepHeader: true, skip: 1, storeDir: params.outDir )

    to_report = align.out.alignments.combine(
        count_reads.out.filter{ id, step, tbl -> step == 'MERGE' }, by: 0
    ).branch { id, alignments, step, count ->
        empty: count == 0
            [id]
        with_alignments: true
            [id, alignments]
    }

    editing_summary(to_report.with_alignments, report_rmd)
    editing_summary.out.mismatched_event_frequencies.collectFile(name: "mismatched_event_frequency_summary.csv", keepHeader: true, skip: 1, storeDir: params.outDir )

}
