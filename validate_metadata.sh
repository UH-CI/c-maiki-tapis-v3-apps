#!/bin/bash

set -e

READS_DIR="${1:-reads}"
METADATA_DIR="${2:-metadata}"

# Cleanup function for all validation failures
cleanup_validation() {
    echo ""
    echo "Cleaning up after metadata validation failure..."
    echo "# of files in reads: $(ls -1 reads 2>/dev/null | wc -l)"
    
    KEEP_FILES=("metadata" "tapisjob.env" "tapisjob.out" "tapisjob.sh")

    for item in *; do
        if [[ ! " ${KEEP_FILES[@]} " =~ " ${item} " ]]; then
            rm -rf "$item" 2>/dev/null || true
        fi
    done
}

# Find metadata file in metadata directory
METADATA_FILE=$(find "$METADATA_DIR" -maxdepth 1 -type f -name "*metadata*.xlsx" | head -n 1)
if [ -z "$METADATA_FILE" ]; then
    echo "Error: No metadata file found in $METADATA_DIR" >&2
    cleanup_validation
    exit 1
fi

if [ ! -f "$METADATA_FILE" ]; then
    echo "Error: Metadata file not found: $METADATA_FILE" >&2
    cleanup_validation
    exit 1
fi

if [ ! -d "$READS_DIR" ]; then
    echo "Error: Reads directory not found: $READS_DIR" >&2
    cleanup_validation
    exit 1
fi

# Count samples in metadata (column A, rows 12+)
SHEET_XML=$(unzip -p "$METADATA_FILE" xl/worksheets/sheet1.xml 2>/dev/null)
if [ -z "$SHEET_XML" ]; then
    echo "Error: Cannot read Excel file" >&2
    cleanup_validation
    exit 1
fi

METADATA_COUNT=$(echo "$SHEET_XML" | grep -o '<c r="A1[2-9][0-9]*"[^>]*><v>[^<]*</v></c>' | wc -l)

# Count unique samples in reads directory
declare -A UNIQUE_SAMPLES
FASTQ_FILES=$(find "$READS_DIR" -maxdepth 1 -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" -o -name "*.fastq" -o -name "*.fq" \))

while IFS= read -r filepath; do
    [ -z "$filepath" ] && continue
    filename=$(basename "$filepath")
    
    if [[ "$filename" =~ ^(.+)_R1(_[0-9]+)?\.(fastq|fq)(\.gz)?$ ]] || [[ "$filename" =~ ^(.+)_1(_[0-9]+)?\.(fastq|fq)(\.gz)?$ ]]; then
        UNIQUE_SAMPLES["${BASH_REMATCH[1]}"]=1
    elif [[ "$filename" =~ ^(.+)_R2(_[0-9]+)?\.(fastq|fq)(\.gz)?$ ]] || [[ "$filename" =~ ^(.+)_2(_[0-9]+)?\.(fastq|fq)(\.gz)?$ ]]; then
        UNIQUE_SAMPLES["${BASH_REMATCH[1]}"]=1
    fi
done <<< "$FASTQ_FILES"

SEQUENCE_COUNT=${#UNIQUE_SAMPLES[@]}

echo "Metadata samples: $METADATA_COUNT"
echo "Sequence samples: $SEQUENCE_COUNT"

if [ "$METADATA_COUNT" -ne "$SEQUENCE_COUNT" ]; then
    echo ""
    echo "Error: Count mismatch"
    echo "reads:"
    ls reads
    cleanup_validation
    exit 1
fi

echo "Validation passed"
exit 0