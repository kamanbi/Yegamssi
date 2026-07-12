import csv
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent


REPLACEMENTS = {
    "en": [
        ("my energy", "your energy"),
        ("My sense", "Your sense"),
        ("my sense", "your sense"),
        ("my greed", "excessive desire"),
        ("my body", "your body"),
        ("my daily life", "your daily life"),
        ("my ordinary day", "your ordinary day"),
        ("my overall sense", "your overall sense"),
        ("in my favor", "in your favor"),
        ("my condition", "your condition"),
        ("my driving force", "your drive"),
        ("my thoughts", "your thoughts"),
        ("my sense", "your sense"),
        ("making decisions on my own", "making decisions alone"),
        ("my concentration", "your concentration"),
        ("my work", "your work"),
        ("my physical condition", "your physical condition"),
        ("I need", "you need"),
        ("I am", "you are"),
        ("I'm", "you're"),
        ("I have", "you have"),
        ("I will", "you will"),
        ("I can", "you can"),
        ("I ", "you "),
        (" me ", " you "),
        (" to me", " to you"),
        (" helps me", " helps you"),
    ],
    "ja": [
        ("私の", "あなたの"),
        ("私は", "あなたは"),
        ("私が", "あなたが"),
        ("私に", "あなたに"),
    ],
    "ro": [
        ("energia mea", "energia ta"),
        ("lăcomia mea", "dorințele excesive"),
        ("în favoarea mea", "în favoarea ta"),
        ("condiția mea fizică", "condiția ta fizică"),
        ("corpul meu", "corpul tău"),
        ("viața mea de zi cu zi", "viața ta de zi cu zi"),
        ("starea mea", "starea ta"),
        ("forța mea motrice", "forța ta de acțiune"),
        ("gândurile mele", "gândurile tale"),
        ("simțul meu", "simțul tău"),
        ("am nevoie", "ai nevoie"),
        ("sunt motivat", "există motivație"),
        ("Sunt motivat", "Există motivație"),
        ("eu ", "tu "),
        (" mă ", " te "),
        (" îmi ", " îți "),
    ],
    "hi": [
        ("मेरी ऊर्जा", "आपकी ऊर्जा"),
        ("मेरे लालच", "अत्यधिक इच्छा"),
        ("मेरी लालच", "अत्यधिक इच्छा"),
        ("मेरे शरीर", "आपके शरीर"),
        ("मेरा शरीर", "आपका शरीर"),
        ("मेरी स्थिति", "आपकी स्थिति"),
        ("मेरी प्रेरक शक्ति", "आपकी प्रेरक शक्ति"),
        ("मेरे विचार", "आपके विचार"),
        ("मुझे ", "आपको "),
        ("मैं ", "आप "),
        ("मेरा ", "आपका "),
        ("मेरी ", "आपकी "),
        ("मेरे ", "आपके "),
    ],
    "zh": [
        ("对我有利", "对你有利"),
        ("帮助我保持", "有助于保持"),
        ("帮助我", "有助于"),
        ("这一天我几乎没有工作动力", "这一天工作动力几乎不足"),
        ("今天是我身体虚弱到无法忍受的一天", "今天你的身体状态非常虚弱，难以承受额外负担"),
        ("我的", "你的"),
        ("我很有动力", "动力很足"),
        ("我做决定的速度很慢", "做决定的速度较慢"),
        ("我有很多事情要思考", "有很多事情需要思考"),
        ("我有很多想法", "思绪较多"),
        ("我缺乏很多整体能量", "整体能量明显不足"),
        ("我的精力", "你的精力"),
        ("我需要", "需要"),
        ("我的整体稳定感", "整体稳定感"),
        ("我今天没有精力", "今天没有足够精力"),
        ("我会充满", "你会充满"),
        ("我的身体", "你的身体"),
        ("我身体", "你的身体"),
        ("我期待着", "可以期待"),
        ("我很难", "可能较难"),
    ],
    "es": [
        ("motivaci?n", "motivación"),
    ],
    "pt": [
        ("H? ", "Há "),
        ("h? ", "há "),
        ("motiva??o", "motivação"),
        ("? preciso", "é preciso"),
        ("me livrar completamente da sua ganância", "deixar completamente os excessos de lado"),
        ("Não tenho energia", "Não há energia suficiente"),
        ("quase não tenho motivação", "há pouquíssima motivação"),
        ("estou ansioso por", "é possível esperar"),
    ],
    "de": [
        ("Mein Gespür", "Ihr Gespür"),
        ("also braucht Sie einen Tag, um Ihre Gier vollständig loszulassen", "daher ist ein Tag nötig, um übermäßigen Ehrgeiz vollständig loszulassen"),
        ("Ihre Gier", "übermäßigen Ehrgeiz"),
    ],
    "fr": [
        ("ma faveur", "votre faveur"),
        ("j’ai donc besoin d’une journée pour abandonner complètement votre cupidité", "il faut donc une journée pour abandonner complètement les excès"),
        ("J’ai donc besoin d’une journée pour abandonner complètement votre cupidité", "Il faut donc une journée pour abandonner complètement les excès"),
        ("Aujourd’hui, votre énergie est au plus bas, il faut donc besoin", "Aujourd’hui, votre énergie est au plus bas, il faut donc"),
        ("car je manque beaucoup d’énergie globale", "car l’énergie globale manque beaucoup"),
        ("j'ai beaucoup", "il y a beaucoup"),
        ("J'ai beaucoup", "Il y a beaucoup"),
        ("je suis lent", "les décisions prennent du temps"),
        ("Je suis lent", "Les décisions prennent du temps"),
        ("je sois motivé", "la motivation soit présente"),
        ("Je suis motivé", "La motivation est présente"),
        ("ma force motrice", "votre force motrice"),
        ("mon énergie", "votre énergie"),
        ("ma cupidité", "les excès"),
        ("m'aide", "aide"),
        ("mes pensées", "les pensées"),
        ("j’ai désespérément besoin", "il faut absolument"),
    ],
}


def postprocess(locale: str) -> int:
    path = BASE_DIR / f"fortune_{locale}.csv"
    with path.open(encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        fieldnames = reader.fieldnames
        rows = list(reader)

    changed = 0
    for row in rows:
        text = row["text"]
        updated = text
        for old, new in REPLACEMENTS[locale]:
            updated = updated.replace(old, new)
        if updated != text:
            row["text"] = updated
            changed += 1

    with path.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    return changed


def main() -> None:
    for locale in REPLACEMENTS:
        print(f"{locale}: changed {postprocess(locale)}")


if __name__ == "__main__":
    main()
