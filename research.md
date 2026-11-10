# 예감씨 홈페이지 리서치

## 현재 구조
- 운영 홈페이지는 `https://yegamssi.netlify.app/`이며 원본은 `F:\homepage\yegamssi\index.html`이다. 단일 HTML에 CSS와 11개 언어 문자열이 있다.
- `netlify.toml`은 `public` 정적 파일과 `netlify/functions`를 배포한다. `public`과 `F:\homepage\upload\yegamssi`에 배포용 자산 복사본이 있다.
- 스크린샷은 모바일 WebP와 그 밖의 화면용 PNG를 사용하고, 페이지 아이콘은 `app-icon.png`를 사용한다.
- 상단 방문자 수는 Netlify Function과 Blobs에 저장한다. 브라우저의 무작위 ID를 한국 시간 날짜별로 중복 제거하며, 총계는 첫 기록부터 누적된다.
- 하단에는 사업자 정보, 저작권 문구와 정책·문의 링크가 있다.

## 제약과 리스크
- 방문자 수는 브라우저 저장소를 지우거나 다른 브라우저를 사용하면 별도 방문으로 집계된다. 자동화 요청과 검증 방문도 포함될 수 있다.
- 저장소를 사용할 수 없거나 집계 서비스가 실패하면 숫자 대신 대시가 표시된다. 과거 방문자 기록은 포함되지 않는다.
- 현재 Flutter 작업 트리에 별도 미커밋 변경이 다수 있다.
