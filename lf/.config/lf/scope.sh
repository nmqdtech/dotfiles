#!/usr/bin/env bash
# =============================================================
#  scope.sh — lf previewer
#  x230 · VoidLinux · st+sixel · dwm
#
#  Args:  $1=FILE  $2=PV_WIDTH  $3=PV_HEIGHT  $4=PV_X  $5=PV_Y
# =============================================================

set -o noclobber
set -o noglob
set -o nounset
set -o pipefail

IFS=$'\n'

FILE_PATH="${1}"
PV_WIDTH="${2:-80}"
PV_HEIGHT="${3:-40}"
# PV_X / PV_Y available for sixel absolute positioning if needed
# PV_X="${4:-0}"
# PV_Y="${5:-0}"

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf '%s' "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"

MIMETYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"

# =============================================================
#  Settings
# =============================================================

HIGHLIGHT_SIZE_MAX=262143     # ~256 KB — skip syntax highlight beyond this
BAT_STYLE="${BAT_STYLE:-plain}"
BAT_THEME="${BAT_THEME:-base16}"

# Smoother sixel in st (single-threaded chafa → no tearing)
export CHAFA_THREADS=1

# =============================================================
#  Helpers
# =============================================================

# Print a dim separator line
separator() {
    printf '\033[38;5;240m%*s\033[0m\n' "${PV_WIDTH}" '' | tr ' ' '─'
}

# =============================================================
#  Directory Preview
# =============================================================

if [ -d "${FILE_PATH}" ]; then
    eza \
        --all \
        --long \
        --group-directories-first \
        --icons \
        --git \
        --color=always \
        "${FILE_PATH}" \
    && exit 0
    exit 1
fi

# =============================================================
#  Extension Dispatch
# =============================================================

handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in

        # ─── Archives ───────────────────────────────────────
        zip|tar|gz|xz|bz2|7z|rar|zst|tbz2|txz|tgz|lz4|lzma)
            ouch list "${FILE_PATH}" 2>/dev/null && exit 0
            ;;

        # ─── PDF ─────────────────────────────────────────────
        pdf)
            # Try rendering first page as sixel
            THUMB="/tmp/lf-pdf-${USER}-$$.png"
            pdftoppm \
                -r 150 \
                -singlefile \
                -png \
                "${FILE_PATH}" \
                "${THUMB%.png}" \
                2>/dev/null \
            && chafa \
                -f sixel \
                --animate off \
                --polite on \
                --size "${PV_WIDTH}x${PV_HEIGHT}" \
                "${THUMB}" \
            && rm -f "${THUMB}" \
            && exit 0
            rm -f "${THUMB}"

            # Fallback: text extraction
            pdftotext \
                -l 10 \
                -nopgbrk \
                -q \
                -- "${FILE_PATH}" - \
            | fmt -w "${PV_WIDTH}" \
            && exit 0
            ;;

        # ─── JSON ────────────────────────────────────────────
        json)
            jq --color-output . "${FILE_PATH}" 2>/dev/null && exit 0
            bat \
                --color=always \
                --paging=never \
                --style="${BAT_STYLE}" \
                --language=json \
                -- "${FILE_PATH}" \
            && exit 0
            ;;

        # ─── TOML / YAML / INI ───────────────────────────────
        toml)
            bat --color=always --paging=never --style="${BAT_STYLE}" \
                --language=toml -- "${FILE_PATH}" && exit 0 ;;
        yml|yaml)
            bat --color=always --paging=never --style="${BAT_STYLE}" \
                --language=yaml -- "${FILE_PATH}" && exit 0 ;;
        ini|conf)
            bat --color=always --paging=never --style="${BAT_STYLE}" \
                --language=ini -- "${FILE_PATH}" && exit 0 ;;

        # ─── Jupyter Notebooks ───────────────────────────────
        ipynb)
            jupyter nbconvert \
                --to markdown \
                "${FILE_PATH}" \
                --stdout 2>/dev/null \
            | bat \
                --color=always \
                --paging=never \
                --style="${BAT_STYLE}" \
                --language=markdown \
            && exit 0
            ;;

        # ─── Markdown ────────────────────────────────────────
        md|markdown|mdx|rmd)
            bat --color=always --paging=never --style="${BAT_STYLE}" \
                --language=markdown -- "${FILE_PATH}" && exit 0
            ;;

        # ─── Go source ───────────────────────────────────────
        go)
            bat --color=always --paging=never --style="${BAT_STYLE}" \
                --language=go -- "${FILE_PATH}" && exit 0
            ;;

        # ─── Rust ────────────────────────────────────────────
        rs)
            bat --color=always --paging=never --style="${BAT_STYLE}" \
                --language=rust -- "${FILE_PATH}" && exit 0
            ;;

        # ─── CSV ─────────────────────────────────────────────
        csv)
            # Pretty-print with column, colorize header
            head -n "${PV_HEIGHT}" "${FILE_PATH}" \
            | column -s, -t \
            | bat --color=always --paging=never --style="${BAT_STYLE}" \
                  --language=tsv \
            && exit 0
            ;;

        # ─── SQLite ──────────────────────────────────────────
        db|sqlite|sqlite3)
            printf '\033[33m Tables:\033[0m\n'
            sqlite3 "${FILE_PATH}" ".tables"
            printf '\n'
            separator
            # Show row counts for each table
            sqlite3 "${FILE_PATH}" ".tables" | tr ' ' '\n' | grep -v '^$' | while read -r tbl; do
                count=$(sqlite3 "${FILE_PATH}" "SELECT COUNT(*) FROM \"${tbl}\";")
                printf "  %-30s \033[36m%s rows\033[0m\n" "${tbl}" "${count}"
            done
            exit 0
            ;;

        # ─── Fonts ───────────────────────────────────────────
        ttf|otf|woff|woff2)
            fc-scan --format "%{family}\n%{style}\n%{file}\n" "${FILE_PATH}" 2>/dev/null && exit 0
            ;;

        # ─── BitTorrent ───────────────────────────────────────
        torrent)
            transmission-show "${FILE_PATH}" 2>/dev/null && exit 0
            ;;

    esac
}

# =============================================================
#  MIME Dispatch
# =============================================================

handle_mime() {
    case "${MIMETYPE}" in

        # ─── Text / Source ───────────────────────────────────
        text/*|*/xml|application/javascript|application/x-shellscript)

            if [ "$(stat --printf='%s' -- "${FILE_PATH}")" -gt "${HIGHLIGHT_SIZE_MAX}" ]; then
                head -n "${PV_HEIGHT}" "${FILE_PATH}"
                exit 0
            fi

            bat \
                --color=always \
                --paging=never \
                --style="${BAT_STYLE}" \
                --theme="${BAT_THEME}" \
                -- "${FILE_PATH}" \
            && exit 0

            highlight \
                --out-format=xterm256 \
                --force \
                -- "${FILE_PATH}" \
            && exit 0

            cat -- "${FILE_PATH}"
            exit 0
            ;;

        # ─── Images → sixel ──────────────────────────────────
        image/*)
            chafa \
                -f sixel \
                --animate off \
                --polite on \
                --size "${PV_WIDTH}x${PV_HEIGHT}" \
                -- "${FILE_PATH}" \
            && exit 0

            # Fallback: metadata
            exiftool "${FILE_PATH}" && exit 0
            ;;

        # ─── SVG → sixel via rsvg-convert ────────────────────
        image/svg+xml)
            THUMB="/tmp/lf-svg-${USER}-$$.png"
            rsvg-convert -o "${THUMB}" "${FILE_PATH}" 2>/dev/null \
            && chafa \
                -f sixel \
                --animate off \
                --polite on \
                --size "${PV_WIDTH}x${PV_HEIGHT}" \
                "${THUMB}" \
            && rm -f "${THUMB}" \
            && exit 0
            rm -f "${THUMB}"
            cat "${FILE_PATH}"
            exit 0
            ;;

        # ─── Video ───────────────────────────────────────────
        video/*)
            THUMB="/tmp/lf-vid-${USER}-$$.jpg"

            ffmpegthumbnailer \
                -i "${FILE_PATH}" \
                -o "${THUMB}" \
                -s 0 \
                -q 8 \
                >/dev/null 2>&1

            if [ -f "${THUMB}" ]; then
                chafa \
                    -f sixel \
                    --animate off \
                    --polite on \
                    --size "${PV_WIDTH}x$((PV_HEIGHT * 2 / 3))" \
                    -- "${THUMB}"
                rm -f "${THUMB}"
            fi

            printf '\n'
            separator
            mediainfo "${FILE_PATH}" 2>/dev/null \
            | grep -E '(Duration|Width|Height|Frame rate|Bit rate|Format|Codec|Channel|Sampling)' \
            | head -20
            exit 0
            ;;

        # ─── Audio ───────────────────────────────────────────
        audio/*)
            # Try to display embedded cover art
            THUMB="/tmp/lf-audio-${USER}-$$.jpg"
            ffmpeg -i "${FILE_PATH}" \
                -an \
                -vcodec copy \
                "${THUMB}" \
                -y \
                >/dev/null 2>&1

            if [ -f "${THUMB}" ]; then
                chafa \
                    -f sixel \
                    --animate off \
                    --polite on \
                    --size "${PV_WIDTH}x$((PV_HEIGHT / 2))" \
                    -- "${THUMB}"
                rm -f "${THUMB}"
            fi

            printf '\n'
            separator
            mediainfo "${FILE_PATH}" 2>/dev/null \
            | grep -E '(Format|Duration|Bit rate|Channel|Sampling|Title|Album|Artist|Genre)' \
            | head -20 \
            || exiftool "${FILE_PATH}"
            exit 0
            ;;

        # ─── HTML ────────────────────────────────────────────
        text/html)
            w3m -dump "${FILE_PATH}" 2>/dev/null && exit 0
            bat --color=always --paging=never --style="${BAT_STYLE}" \
                --language=html -- "${FILE_PATH}" && exit 0
            ;;

        # ─── ELF binaries ────────────────────────────────────
        application/x-executable|\
        application/x-pie-executable|\
        application/x-sharedlib)
            readelf -WCa "${FILE_PATH}" 2>/dev/null | head -100 && exit 0
            ;;

        # ─── Desktop entry ───────────────────────────────────
        application/x-desktop)
            bat --color=always --paging=never --style="${BAT_STYLE}" \
                --language=ini -- "${FILE_PATH}" && exit 0
            ;;

        # ─── Office / EPUB ───────────────────────────────────
        application/vnd.openxmlformats-officedocument.wordprocessingml.document|\
        application/msword)
            docx2txt "${FILE_PATH}" - 2>/dev/null | head -100 && exit 0
            ;;

        application/epub+zip)
            epub2txt "${FILE_PATH}" 2>/dev/null | head -100 && exit 0
            ;;

    esac
}

# =============================================================
#  Fallback
# =============================================================

handle_fallback() {
    printf '\033[33m  No preview available\033[0m\n\n'
    file --dereference --brief -- "${FILE_PATH}"
    printf '\n'
    stat --printf="Size: %s bytes\nModified: %y\nPermissions: %A\n" -- "${FILE_PATH}"
}

# =============================================================
#  Main
# =============================================================

handle_extension
handle_mime
handle_fallback

exit 1
