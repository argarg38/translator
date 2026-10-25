---
name: 번역
description: PDF를 PDFMathTranslate(pdf2zh)로 레이아웃·수식을 유지한 채 한국어로 번역한다. 사용자가 PDF를 올리거나 "/번역", "번역해줘", "translate this PDF"라고 할 때 사용.
---

# PDF 번역 (pdf2zh + Gemini)

사용자에게 질문하지 말고 아래 순서대로 바로 진행한다. 끝나면 결과 파일만 짧게 알려준다.

## 1. 준비 확인

```bash
command -v pdf2zh || uv tool install --python 3.12 pdf2zh \
  --with "tencentcloud-sdk-python-tmt<3.1" \
  --with "tencentcloud-sdk-python-common<3.1" \
  --with "bitstring<5"
[ -n "${GEMINI_API_KEY:-}" ] && echo "gemini ok" || echo "GEMINI_API_KEY 없음"
```

- `GEMINI_API_KEY`가 없으면 멈추고 알린다: 환경 설정의 Environment variables에 `GEMINI_API_KEY`(https://aistudio.google.com/apikey 에서 무료 발급)와 `GEMINI_MODEL=gemini-flash-latest`를 넣고 새 세션을 열어야 한다. 클라우드 IP에서는 Google·Bing 무료 번역이 차단되므로 대체 엔진으로 넘어가지 않는다.

## 2. 대상 PDF 찾기

- 메시지에 첨부·업로드된 PDF 경로가 있으면 그것을 쓴다.
- 없으면 `find / -name "*.pdf" -mmin -60 -not -path "*/proc/*" -not -path "*/site-packages/*" -not -path "*/output/*" 2>/dev/null`로 최근 올라온 PDF를 찾는다.
- 그래도 없으면 PDF를 올려달라고만 말한다.
- 페이지 범위를 말했으면 `--pages 1-5` 형식으로 넘긴다.

## 3. 번역

출력은 사용자가 앱에서 열 수 있도록 레포의 `output/` 폴더에 둔다.

번역문 글꼴은 고딕체로 맞춘다. 원문 영문 글꼴(Arial 등)에는 한글 글리프가 없어 그대로 쓸 수 없고, pdf2zh 기본값은 명조체(SourceHanSerifKR)라 슬라이드와 어울리지 않는다. `set-font.sh`가 아래 순서로 글꼴을 골라 pdf2zh 설정에 기록하므로 번역 전에 매번 실행한다.

1. `KO_FONT` 환경 변수로 지정한 글꼴 파일
2. `fonts/malgun.ttf`: 사용자가 맑은 고딕 파일을 올리면 여기에 복사한다. Microsoft 라이선스 글꼴이라 레포에 커밋하지 않는다.
3. `fonts/Pretendard-Regular.otf`: 기본값. 맑은 고딕과 비슷한 고딕체이며 OFL 라이선스로 레포에 포함했다.

```bash
/home/user/translator/.claude/skills/번역/set-font.sh
mkdir -p /home/user/translator/output
GEMINI_MODEL="${GEMINI_MODEL:-gemini-flash-latest}" \
  pdf2zh "<입력.pdf>" -li en -lo ko -s gemini -t 4 -o /home/user/translator/output
```

- 원문 언어가 영어가 아니면 `-li`를 맞춘다(일본어 `ja`, 중국어 `zh` 등). 목표 언어는 요청이 없으면 `ko`.
- 오래 걸릴 수 있으니 timeout을 넉넉히(최대 600000ms) 주고, 큰 파일은 백그라운드로 돌린다.
- 로그에 `ERROR:pdf2zh.converter`가 반복되면 번역이 실패한 것이다. 원인(429 할당량 초과, 403 도메인 차단, 모델명 오류 등)을 로그에서 확인해 알린다. 실패한 결과를 성공이라고 보고하지 않는다.
- 429면 `-t 1`로 낮춰 한 번 다시 시도한다.

## 4. 결과 전달

- `<이름>-mono.pdf`(번역본)와 `<이름>-dual.pdf`(원문·번역 대조본)를 `SendUserFile`로 보낸다.
- `pymupdf`로 첫 페이지 텍스트 일부를 뽑아 한국어가 들어갔는지 확인한 뒤 보고한다:
  `/root/.local/share/uv/tools/pdf2zh/bin/python -c "import pymupdf,sys; print(pymupdf.open(sys.argv[1])[0].get_text()[:300])" <파일>`
- `output/`은 git에 커밋하지 않는다.
