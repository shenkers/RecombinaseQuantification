
process editing_summary {

    container = params.r_container

    memory 1500.MB

    publishDir params.outDir

    input:
        tuple( val(id), path('alignments.csv.gz') )
        path(markdown)
    output:
        path("*.editing_summary.html")
        path( "event_frequencies.csv", emit: event_frequencies )
        path( "mismatched_event_frequencies.csv", emit: mismatched_event_frequencies )

    publishDir params.outDir, saveAs : {filename -> "05_report/${id}/${filename}"}, mode: 'copy'

    script:
    """
    cp $markdown report.Rmd
    Rscript -e "rmarkdown::render('report.Rmd', \\
            output_file = '${id}.editing_summary.html', \\
            params=list( id='${id}', alignments_csv='alignments.csv.gz' ) 
    )"
    """
}
