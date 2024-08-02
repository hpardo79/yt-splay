#!/bin/bash
# --------------------------------------------------------------------------------
# YT-SPLAY
# It is a shell script to Search and Play Youtube videos in terminal.
# Author: Hector Pardo
# --------------------------------------------------------------------------------

search_and_play() {
    while true; do
        echo -n "Enter search term (or type 'exit' to quit): "
        read -r SEARCH_TERM
        
        if [ "$SEARCH_TERM" == "exit" ]; then
            exit_program
        fi
        
        perform_search "$SEARCH_TERM"

        if [ -z "$RESULTS" ]; then
            echo "No videos found for search term: $SEARCH_TERM"
            continue
        fi

        display_results

        while true; do
            echo -n "Enter the number of the video to play (or '0' to search again): "
            read -r SELECTION

            if [ "$SELECTION" -eq 0 ]; then
                break
            fi

            if ! play_video "$SELECTION"; then
                echo "Failed to play video. Would you like to try again with the same search? (y/n): "
                read -r RETRY

                if [ "$RETRY" == "n" ]; then
                    break
                fi
            else
                break
            fi
        done
    done
}

perform_search() {
    SEARCH_TERM="$1"
    RESULTS=$(yt-dlp "ytsearch10:$SEARCH_TERM" --get-title --get-id --default-search "ytsearch" --no-warnings | paste -d " " - -)
}

display_results() {
    echo "Search results for '$SEARCH_TERM':"
    echo "$RESULTS" | nl -w 2 -s '. '
}

play_video() {
    SELECTION="$1"
    VIDEO_ID=$(echo "$RESULTS" | sed -n "${SELECTION}p" | awk '{print $NF}')
    FULL_URL="https://www.youtube.com/watch?v=$VIDEO_ID"

    if [ -z "$VIDEO_ID" ]; then
        echo "Invalid selection."
        return 1
    fi

    FORMAT="bestvideo[height=480][ext=mp4]+bestaudio[ext=m4a]/best[height=480][ext=mp4]"
    mpv --ytdl-format="$FORMAT" "$FULL_URL"
    return $?
}

exit_program() {
    echo "Exiting program."
    exit 0
}

# Main loop
search_and_play
