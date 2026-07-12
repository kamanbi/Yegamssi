import csv
import re
import unicodedata
from collections import Counter
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
CSV_PATH = BASE_DIR / "fortune_vi.csv"
FIELDNAMES = ["code", "type", "text", "weight"]


EXACT_REPLACEMENTS = {
    "Họ có ý thức tài chính nhạy bén và phát hiện chính xác các cơ hội lợi nhuận.": (
        "Khả năng cảm nhận tài chính của bạn rất nhạy bén, giúp bạn nhận ra chính xác các cơ hội sinh lời."
    ),
    "Năng lượng tình yêu hôm nay dồi dào nên tôi rất mong chờ những cuộc gặp gỡ thú vị và những mối quan hệ ngày càng sâu sắc hơn.": (
        "Năng lượng tình yêu hôm nay dồi dào, nên bạn có thể mong chờ những cuộc gặp gỡ thú vị và các mối quan hệ ngày càng sâu sắc hơn."
    ),
    "Hôm nay, tôi sẽ tràn đầy năng lượng lành mạnh nên cơ thể sẽ nhẹ nhàng và cuộc sống hàng ngày sẽ trôi chảy.": (
        "Hôm nay, năng lượng sức khỏe hỗ trợ bạn tốt, giúp cơ thể nhẹ nhàng hơn và nhịp sống hằng ngày trôi chảy hơn."
    ),
    "Hôm nay là một ngày mà cơ thể tôi khá yếu và tôi rất cần được nghỉ ngơi đầy đủ.": (
        "Hôm nay, cơ thể bạn khá yếu nên việc nghỉ ngơi đầy đủ là điều rất cần thiết."
    ),
    "Hôm nay là một ngày mà thể trạng của tôi yếu đến mức không thể chịu đựng được nỗ lực nào.": (
        "Hôm nay, thể trạng của bạn rất yếu nên không nên cố gắng quá sức dưới bất kỳ hình thức nào."
    ),
    "Tôi không còn sức lực để đưa ra quyết định ngày hôm nay, vì vậy thà tham khảo ý kiến của người khác còn hơn là tự mình đưa ra quyết định.": (
        "Hôm nay, năng lượng quyết định của bạn khá yếu, nên tham khảo ý kiến người khác sẽ tốt hơn là tự mình phán đoán."
    ),
}


PHRASE_REPLACEMENTS = [
    ("Ngày nay,", "Hôm nay,"),
    ("Ngày nay", "Hôm nay"),
    ("ngày nay", "hôm nay"),
    ("của tôi", "của bạn"),
    ("giúp tôi", "giúp bạn"),
    ("cho tôi", "cho bạn"),
    ("khiến tôi", "khiến bạn"),
    ("tôi có", "bạn có"),
    ("Tôi có", "Bạn có"),
    ("tôi chậm", "bạn chậm"),
    ("Dù tôi", "Dù bạn"),
    ("Mặc dù tôi", "Mặc dù bạn"),
    ("Hôm nay tôi", "Hôm nay bạn"),
    ("Hôm nay, tôi", "Hôm nay, bạn"),
    ("Cả ngày thật khó khăn vì tôi thiếu", "Cả ngày có thể khá khó khăn vì bạn thiếu"),
    ("tôi thiếu", "bạn thiếu"),
    ("tôi cần", "bạn cần"),
    ("Khả năng đọc diễn biến của tôi", "Khả năng đọc diễn biến của bạn"),
    ("Đó là ngày tôi", "Đó là ngày bạn"),
    ("cơ thể tôi", "cơ thể bạn"),
    ("thể trạng của tôi", "thể trạng của bạn"),
    ("tôi", "bạn"),
    ("Tôi", "Bạn"),
]


POLISH_REPLACEMENTS = [
    ("năng lượng nhiều mây", "nguồn năng lượng trầm"),
    ("năng lượng đục", "nguồn năng lượng trầm"),
    ("năng lượng u ám", "nguồn năng lượng trầm"),
    ("năng lượng âm u", "nguồn năng lượng trầm"),
    ("năng lượng trong trẻo", "nguồn năng lượng sáng rõ"),
    ("năng lượng trong sáng", "nguồn năng lượng sáng rõ"),
    ("năng lượng ẩm ướt", "nguồn năng lượng mềm mại"),
    ("không chút do dự", "không quá xáo trộn"),
    ("tốc độ vừa phải", "nhịp độ vừa phải"),
    ("nhịp độ thoải mái", "nhịp độ ổn định"),
    ("sự giàu có hôm nay", "vận tài lộc hôm nay"),
    ("Năng lượng tiền bạc hôm nay", "Năng lượng tài chính hôm nay"),
    ("tiết kiệm và tiết kiệm", "tiết kiệm và kiểm soát chi tiêu"),
    ("quản lý các điều kiện đặc biệt", "chăm sóc thể trạng đặc biệt"),
    ("di chuyển càng ổn định càng tốt với năng lượng làm việc tạm lắng là điều thuận lợi", "giữ nhịp làm việc ổn định sẽ có lợi hơn khi năng lượng công việc đang chững lại"),
]


def load_rows() -> list[dict[str, str]]:
    with CSV_PATH.open(encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        if reader.fieldnames != FIELDNAMES:
            raise ValueError(f"invalid header: {reader.fieldnames}")
        return list(reader)


def save_rows(rows: list[dict[str, str]]) -> None:
    with CSV_PATH.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(rows)


def review_text(text: str) -> str:
    reviewed_text = unicodedata.normalize("NFC", text).strip()
    reviewed_text = EXACT_REPLACEMENTS.get(reviewed_text, reviewed_text)
    for source_text, replacement_text in PHRASE_REPLACEMENTS:
        reviewed_text = reviewed_text.replace(source_text, replacement_text)
    for source_text, replacement_text in POLISH_REPLACEMENTS:
        reviewed_text = reviewed_text.replace(source_text, replacement_text)
    reviewed_text = re.sub(r"\s+", " ", reviewed_text).strip()
    return reviewed_text


def vietnamese_words(text: str) -> list[str]:
    normalized_text = unicodedata.normalize("NFC", text)
    return re.findall(r"[^\W\d_]+", normalized_text, flags=re.UNICODE)


def audit_rows(rows: list[dict[str, str]]) -> Counter[str]:
    issues: Counter[str] = Counter()
    for row in rows:
        text = unicodedata.normalize("NFC", row["text"])
        words = set(vietnamese_words(text))
        if re.search(r"[가-힣]", text):
            issues["hangul"] += 1
        if not text:
            issues["empty_text"] += 1
        if "Ngày nay" in text or "ngày nay" in text:
            issues["ngay_nay"] += 1
        if "Họ" in words or "họ" in words:
            issues["wrong_subject_ho"] += 1
        if "Tôi" in words or "tôi" in words:
            issues["first_person_toi"] += 1
        if re.search(r"YEGAMSSI|SEPARATOR|Google|bản dịch", text, re.IGNORECASE):
            issues["translation_artifact"] += 1
        if not re.search(r"[.!?…]$", text):
            issues["missing_terminal_punctuation"] += 1
        if not row["weight"].isdigit() or int(row["weight"]) <= 0:
            issues["invalid_weight"] += 1
    return issues


def main() -> None:
    rows = load_rows()
    changed_count = 0
    for row in rows:
        reviewed_text = review_text(row["text"])
        if reviewed_text != row["text"]:
            changed_count += 1
            row["text"] = reviewed_text

    issues = audit_rows(rows)
    blocking_issues = {
        key: count
        for key, count in issues.items()
        if count > 0
    }
    if blocking_issues:
        raise RuntimeError(f"Vietnamese copy QA failed: {dict(blocking_issues)}")

    save_rows(rows)
    print(f"fortune_vi reviewed rows={len(rows)} changed_rows={changed_count}")


if __name__ == "__main__":
    main()
