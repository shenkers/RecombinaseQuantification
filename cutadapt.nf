complement = [ A: 'T', T: 'A', G: 'C', C: 'G' ]

def reverseComplement(dna){
    if( !dna.matches('^[ATGC]*$') ) throw new Exception("Cannot reverse-complement string '$dna'")
    dna.split("").reverse().collect{ complement[it] }.join('') ?: ''
}

process trim_primers {

  input:
      tuple val(id), path('R1.fastq.gz'), path('R2.fastq.gz'), val(forward_primer), val(reverse_primer)

  output:
      tuple val(id), path("R1.trimmed.fastq.gz"), path("R2.trimmed.fastq.gz"), emit: trimmed_fastq
      path "*report.txt"

  container 'quay.io/biocontainers/cutadapt:4.5--py39hf95cd2a_0'

  publishDir params.outDir, saveAs : {filename -> "02_cutadapt/${id}/${filename}"}

  script:

  """
  cutadapt \
  --discard-untrimmed \
  --minimum-length 80 \
  -a "^${forward_primer}...${reverseComplement(reverse_primer)}NNNNNNNNNN;max_error_rate=0.2" \
  -A ^${reverse_primer}...${reverseComplement(forward_primer)} \
  -o R1.trimmed.fastq.gz -p R2.trimmed.fastq.gz \
  R1.fastq.gz R2.fastq.gz > ${id}_trimming_report.txt
  """
}
