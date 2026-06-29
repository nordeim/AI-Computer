I've appended Appendix B: Linux Configuration — Lessons Learned to the skill file (now 970 lines). The new section covers: 
                               
1. Key differences from macOS — bash vs zsh, systemd vs launchd, binary locations 
2. The critical insight — ~/.claude/settings.json env block is the only reliable mechanism on Linux (not shell env vars)  
3. Step-by-step configuration — exact files to create and their contents 
4. Tips & best practices — 6 hard-won tips including auth token arbitrariness, model name matching, and harmless warning messages 
5. Challenges encountered & solutions — table of 4 real issues from this session with root causes and fixes 
6. Troubleshooting — 4 common problems with diagnostic commands 
7. systemd user service — for auto-start on Linux (replacing macOS launchd) 
8. Verification checklist — 5-item checklist to confirm everything works 
9. Linux file structure — complete reference tree
