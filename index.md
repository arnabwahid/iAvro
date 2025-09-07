# iAvro — Working Notes

For instructions on how we capture and maintain the engineering chat log, see:

- Session‑based chatlog workflow (default): `tools/CHATLOG_USAGE.md`
- Consolidated chatlog (rebuilt from sessions): `docs/chatlog.md`
- Rolling context & decisions (not a transcript): `docs/export.md`

Short version:
1) Put verbatim text in `docs/continue_chat.txt`
2) Preferred: run task “New Session CC” (creates session + rebuilds chatlog)
3) Or run separately: “New Session (from continue chat)” then “Build Chatlog (sessions → chatlog.md)”

This keeps history clean and avoids merge conflicts. Immediate append tasks are available if needed.
