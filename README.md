![CI](https://github.com/arnabwahid/iAvro/actions/workflows/ci.yml/badge.svg?branch=dev)

Installation
------------

1. Download the `tar.gz` file from [Releases Section](https://github.com/torifat/iAvro/releases)
2. Extract the `tar.gz` & copy `Avro Keyboard.app` file
3. Goto `Finder` & press `⌘⇧G`, paste `~/Library/Input Methods/` & `Go`
4. Paste the `Avro Keyboard.app` file here
5. Goto `System Preferences -> Language & Text -> Input Sources` & Check `Avro Keyboard` from the list
6. Look Above :P

Phase B: Context‑Aware Ranking (Dev Feature)
-------------------------------------------
- Feature flag: `ContextRankingEnabled` (stored in app preferences). When ON, the IME learns lightweight bigrams from committed tokens and boosts contextually likely candidates.
- Persistence: learned bigrams are stored locally in `NSUserDefaults` under `ContextRankingBigrams` with conservative caps and decay.
- Reset: to clear learned context, run the VS Code task “Reset Learned Context” or execute:

  `bash tools/reset-context.sh`

- Toggle via terminal (optional):
  - Disable: `defaults write com.omicronlab.inputmethod.AvroKeyboard ContextRankingEnabled -bool NO`
  - Enable: `defaults write com.omicronlab.inputmethod.AvroKeyboard ContextRankingEnabled -bool YES`

Docs & Checklists
-----------------
- Phase A checklist: `docs/PHASE_A_CHECKLIST.md`
- Phase B checklist: `docs/PHASE_B_CHECKLIST.md`
