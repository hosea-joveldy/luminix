#!/usr/bin/env python3
import base64
import json
import mimetypes
import os
import struct
import subprocess
import sys
import time
import urllib.parse

SEP = "\x1f"
FORMAT = SEP.join(["{{status}}", "{{xesam:title}}", "{{xesam:artist}}", "{{mpris:artUrl}}", "{{playerName}}", "{{position}}", "{{mpris:length}}"])
MAX_ART = 600_000
POLL_SECONDS = 1.0

_art_cache = ("", "")


def send(msg):
    data = json.dumps(msg, ensure_ascii=False).encode("utf-8")
    sys.stdout.buffer.write(struct.pack("=I", len(data)) + data)
    sys.stdout.buffer.flush()


def art_data(url):
    global _art_cache
    if not url:
        return ""
    if _art_cache[0] == url:
        return _art_cache[1]
    result = ""
    if url.startswith("file://"):
        path = urllib.parse.unquote(urllib.parse.urlparse(url).path)
        try:
            if os.path.getsize(path) <= MAX_ART:
                mime = mimetypes.guess_type(path)[0] or "image/jpeg"
                with open(path, "rb") as f:
                    result = f"data:{mime};base64," + base64.b64encode(f.read()).decode()
        except OSError:
            result = ""
    elif url.startswith(("https://", "data:")):
        result = url if len(url) <= MAX_ART else ""
    _art_cache = (url, result)
    return result


def to_int(v):
    try:
        return int(float(v))
    except ValueError:
        return 0


def query():
    try:
        out = subprocess.run(
            ["playerctl", "--all-players", "metadata", "--format", FORMAT],
            capture_output=True,
            text=True,
            timeout=3,
        )
    except (OSError, subprocess.TimeoutExpired):
        return {"active": False}
    players = []
    for line in out.stdout.splitlines():
        parts = line.split(SEP)
        if len(parts) == 7:
            players.append(parts)
    for wanted in ("Playing", "Paused"):
        for status, title, artist, art, name, pos, length in players:
            if status == wanted:
                return {
                    "active": True,
                    "status": status,
                    "title": title,
                    "artist": artist,
                    "art": art_data(art),
                    "player": name,
                    "position": to_int(pos),
                    "length": to_int(length),
                }
    return {"active": False}


def main():
    last = None
    while True:
        msg = query()
        if msg != last:
            send(msg)
            last = msg
        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    try:
        main()
    except (BrokenPipeError, KeyboardInterrupt):
        sys.exit(0)
