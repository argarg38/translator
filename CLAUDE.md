# translator

PDF 번역 전용 레포. 사용자가 PDF만 올리고 아무 말이 없거나 "번역"이라고만 해도 `번역` 스킬(`.claude/skills/번역/SKILL.md`)을 바로 실행해 한국어로 번역한다. 되묻지 않는다.

- 번역 도구: PDFMathTranslate(`pdf2zh`), 엔진은 Gemini(`GEMINI_API_KEY` 환경 변수).
- 세션 시작 시 `.claude/hooks/session-start.sh`가 pdf2zh를 설치한다.
- 번역문 글꼴은 고딕체(기본 `fonts/Pretendard-Regular.otf`, `fonts/malgun.ttf`가 있으면 맑은 고딕)로, 번역 전에 `.claude/skills/번역/set-font.sh`를 실행해 설정한다.
- 결과물은 `output/`에 저장하며 커밋하지 않는다.
