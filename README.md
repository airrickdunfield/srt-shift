# srt-shift

Shift every timestamp in an `.srt` subtitle file by a number of milliseconds, so the subtitles line up with the movie.

## Setup

Make the script executable (one time):

```bash
chmod +x srt-shift.sh
```

Optional: to run it from anywhere as `srt-shift`, add this line to your shell config (`~/.zshrc` or `~/.bashrc`), replacing the path with wherever you saved the script, then open a new terminal:

```bash
alias srt-shift="/path/to/srt-shift.sh"
```

## Usage

```bash
srt-shift movie.srt          # asks you for the delay
srt-shift movie.srt 1500     # subs appear 1.5 s later
srt-shift movie.srt -750     # subs appear 0.75 s earlier
```

(Without the alias, run `./srt-shift.sh` from the script's folder, or use its full path.)

- **Positive** numbers delay the subtitles (use when the subs show up too early).
- **Negative** numbers make them earlier (use when the subs show up too late).
- 1000 ms = 1 second.

## Output

The result is saved next to the original as `movie.shifted.srt`. The original file is not changed, so you can try different values until the timing is right.

To have your player pick it up automatically, rename it so it matches the movie's filename (e.g. `movie.mkv` → `movie.srt`).

## Notes

- If a negative delay would push a subtitle before the start of the movie, that timestamp is set to `00:00:00,000` and the script tells you how many were affected.
- Windows (CRLF) line endings are preserved.
