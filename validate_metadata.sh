#!/bin/bash

set -e

READS_DIR="${1:-reads}"
METADATA_DIR="${2:-metadata}"

VALIDATION_ERRORS="metadata_validation_errors.txt"

# Cleanup function for all validation failures
cleanup_validation() {
    echo ""
    echo "Cleaning up after metadata validation failure..."
    echo "# of files in reads: $(ls -1 reads 2>/dev/null | wc -l)"
    
    KEEP_FILES=("metadata" "tapisjob.env" "tapisjob.out" "tapisjob.sh" "$VALIDATION_ERRORS")

    for item in *; do
        if [[ ! " ${KEEP_FILES[@]} " =~ " ${item} " ]]; then
            rm -rf "$item" 2>/dev/null || true
        fi
    done
}

# ---------------------------------------------------------------------------
# Directory and file checks
# ---------------------------------------------------------------------------

if [ ! -d "$METADATA_DIR" ]; then
    echo "Error: Metadata directory not found: $METADATA_DIR" >&2
    cleanup_validation
    exit 1
fi

# Look for any file whose name contains "metadata" with an .xlsx extension
METADATA_FILE=$(find "$METADATA_DIR" -maxdepth 1 -type f -name "*metadata*.xlsx" | head -n 1)
if [ -z "$METADATA_FILE" ]; then
    echo "Error: No metadata file found in $METADATA_DIR" >&2
    cleanup_validation
    exit 1
fi

if [ ! -d "$READS_DIR" ]; then
    echo "Error: Reads directory not found: $READS_DIR" >&2
    cleanup_validation
    exit 1
fi

# ---------------------------------------------------------------------------
# Parse Excel: extract samp_name values (column B, rows 12+)
# ---------------------------------------------------------------------------
SHEET_XML=$(unzip -p "$METADATA_FILE" xl/worksheets/sheet1.xml 2>/dev/null)
if [ -z "$SHEET_XML" ]; then
    echo "Error: Cannot read Excel file" >&2
    cleanup_validation
    exit 1
fi

SHARED_STRINGS_XML=$(unzip -p "$METADATA_FILE" xl/sharedStrings.xml 2>/dev/null || true)

# Build ordered array of shared strings (index 0, 1, 2, ...)
# Each <si> element in xl/sharedStrings.xml corresponds to one index.
declare -a SHARED_STRINGS=()
if [ -n "$SHARED_STRINGS_XML" ]; then
    while IFS= read -r val; do
        SHARED_STRINGS+=("$val")
    done < <(echo "$SHARED_STRINGS_XML" | \
        grep -o '<t>[^<]*</t>\|<t/>' | \
        sed 's|<t>\(.*\)</t>|\1|; s|<t/>||')
fi

# Extract samp_name values from column B cells at row >= 12
declare -a METADATA_NAMES=()
while IFS= read -r line; do
    [ -n "$line" ] && METADATA_NAMES+=("$line")
done < <(
    echo "$SHEET_XML" | \
    # Put each cell element on its own line for easier processing
    sed 's/<c /\n<c /g' | \
    grep 'r="B[0-9]' | \
    while IFS= read -r cell; do
        # Pull the row number out of the cell reference (e.g. B12 -> 12)
        row=$(echo "$cell" | sed 's/.*r="B\([0-9]\+\)".*/\1/')
        [ "$row" -lt 12 ] 2>/dev/null && continue

        if echo "$cell" | grep -q 't="s"'; then
            # Shared string: <v> holds index into SHARED_STRINGS array
            raw_val=$(echo "$cell" | grep -o '<v>[^<]*</v>' | sed 's|<v>\(.*\)</v>|\1|')
            if [ -n "$raw_val" ]; then
                idx=$((raw_val))
                if [ "$idx" -lt "${#SHARED_STRINGS[@]}" ]; then
                    echo "${SHARED_STRINGS[$idx]}"
                fi
            fi
        elif echo "$cell" | grep -q 't="inlineStr"'; then
            # Inline string: text is inside <is><t>...</t></is>
            echo "$cell" | grep -o '<t>[^<]*</t>' | sed 's|<t>\(.*\)</t>|\1|' | head -n 1
        else
            # Direct value — whatever is in the <v> tag as-is
            raw_val=$(echo "$cell" | grep -o '<v>[^<]*</v>' | sed 's|<v>\(.*\)</v>|\1|')
            [ -n "$raw_val" ] && echo "$raw_val"
        fi
    done
)

METADATA_COUNT=${#METADATA_NAMES[@]}

if [ "$METADATA_COUNT" -eq 0 ]; then
    echo "Error: No metadata entries found in Excel file" >&2
    cleanup_validation
    exit 1
fi

echo "Metadata samples: $METADATA_COUNT"

# ---------------------------------------------------------------------------
# Normalize - collapse consecutive underscores to a single underscore and trim leading/trailing underscores.
# ---------------------------------------------------------------------------
normalize() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/__*/_/g; s/^_//; s/_$//'
}

# ---------------------------------------------------------------------------
# Validate the remainder of a basename after a metadata name prefix match.
# The remainder must be either empty (exact match) or start with a recognized
# sequencer-injected suffix token. This prevents short metadata names like
# "RUN-9" from falsely matching "RUN-9-extended" filenames.
#
# Remainder must be empty (exact match) or start with a known sequencer
# suffix token: _s1, _l001, _r1, _r2, _i1, _i2, _001, etc.
# ---------------------------------------------------------------------------
is_valid_remainder() {
    local remainder="$1"
    [ -z "$remainder" ]                    && return 0
    [[ "$remainder" =~ ^_s[0-9] ]]         && return 0
    [[ "$remainder" =~ ^_l[0-9] ]]         && return 0
    [[ "$remainder" =~ ^_r[12] ]]          && return 0
    [[ "$remainder" =~ ^_i[12] ]]          && return 0
    [[ "$remainder" =~ ^_[0-9] ]]          && return 0
    return 1
}

# ---------------------------------------------------------------------------
# Validate FASTQ files against metadata sample names
#
# - Normalize both the metadata name and the FASTQ basename
# - The normalized metadata name must appear at position 0 of the
#   normalized basename (left-anchored)
# - The remainder after the match must be empty or start with a recognized
#   sequencer suffix token (see is_valid_remainder)
#
# Skip I1/I2 index read files.
#
# R1 and R2 files are validated independently.
# Every sequence input file must be accounted for in the metadata.
# ---------------------------------------------------------------------------

TOTAL_FILES=0
UNMATCHED_FILES=()

while IFS= read -r filepath; do
    [ -z "$filepath" ] && continue

    filename=$(basename "$filepath")

    # Strip known double and single extensions
    case "$filename" in
        *.fastq.gz) base="${filename%.fastq.gz}" ;;
        *.fq.gz)    base="${filename%.fq.gz}" ;;
        *.fastq)    base="${filename%.fastq}" ;;
        *.fq)       base="${filename%.fq}" ;;
        *)          continue ;;
    esac

    # Skip I1 and I2 index reads (case-insensitive, end-anchored)
    # Also matches when a number follows, e.g. _I1_001.
    if [[ "$base" =~ _[Ii][12](_[0-9]+)?$ ]]; then
        echo "Skipping index read file: $filename"
        continue
    fi

    TOTAL_FILES=$((TOTAL_FILES + 1))

    norm_base=$(normalize "$base")

    # Check each metadata name to see if it matches the start of this basename
    matched=0
    for meta_name in "${METADATA_NAMES[@]}"; do
        norm_meta=$(normalize "$meta_name")

        # Left-anchored glob match: does the basename start with this metadata name
        if [[ "$norm_base" == "$norm_meta"* ]]; then
            # Check that what follows is a valid sequencer suffix
            remainder="${norm_base#$norm_meta}"
            if is_valid_remainder "$remainder"; then
                matched=1
                # FOR DEBUG: 
                # echo "  MATCH: $filename -> $meta_name"
                break
            fi
        fi
    done

    if [ "$matched" -eq 0 ]; then
        UNMATCHED_FILES+=("$filename")
        # FOR DEBUG: 
        # echo "  NO MATCH: $filename (normalized: $norm_base)"
    fi

done < <(find "$READS_DIR" -type f \( \
    -name "*.fastq.gz" -o -name "*.fq.gz" \
    -o -name "*.fastq"  -o -name "*.fq" \))

# ---------------------------------------------------------------------------
# Error reporting
# ---------------------------------------------------------------------------

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo ""
    echo "Error: No FASTQ files found in $READS_DIR" >&2
    cleanup_validation
    exit 1
fi

if [ "${#UNMATCHED_FILES[@]}" -gt 0 ]; then
    {
        echo "Error: ${#UNMATCHED_FILES[@]} of $TOTAL_FILES FASTQ file(s) have no matching metadata entry:"
        echo ""
        for f in "${UNMATCHED_FILES[@]}"; do
            echo "  - $f"
        done
        echo ""
        echo "Ensure sample names in column B (samp_name) of the metadata file match the beginning of each filename."
    } > "$VALIDATION_ERRORS"
    echo "" >&2
    echo "Error: ${#UNMATCHED_FILES[@]} of $TOTAL_FILES FASTQ file(s) have no matching metadata entry." >&2
    echo "See $VALIDATION_ERRORS for details." >&2
    cleanup_validation
    exit 1
fi

echo "Sequence files: $TOTAL_FILES"
echo "Validation passed"
exit 0