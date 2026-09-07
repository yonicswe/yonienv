#!/bin/bash
#!/bin/bash
CMD='du -sh ~/* ~/.??* 2>/dev/null | sort -hr | head -30'
echo "Running:"
echo "  $CMD"
echo
tmpfile=$(mktemp)
start_time=$(date +%s)
bash -c "$CMD" > "$tmpfile" &
pid=$!
while kill -0 "$pid" 2>/dev/null; do
    elapsed=$(( $(date +%s) - start_time ))
    printf "\rElapsed: %02d:%02d:%02d" \
        $((elapsed / 3600)) \
        $(((elapsed % 3600) / 60)) \
        $((elapsed % 60))
    sleep 1
done
wait "$pid"
echo
echo
echo "Results:"
cat "$tmpfile"
rm -f "$tmpfile"
