# iAvro — Working Notes

For instructions on how we capture and maintain the engineering chat log, see:

- Session‑based chatlog workflow (default): `tools/CHATLOG_USAGE.md`
- Consolidated chatlog (rebuilt from sessions): `docs/chatlog.md`
- Rolling context & decisions (not a transcript): `docs/export.md`

Short version:
1) Put verbatim text in `docs/pending_chat_append.txt`
2) Run task “New Session (from pending)”
3) Run task “Build Chatlog (sessions → chatlog.md)”

This keeps history clean and avoids merge conflicts. Immediate append tasks are available if needed.

