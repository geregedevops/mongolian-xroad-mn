---
title: Жижиг жишээ документ
version: 0.1.0
owner: Toolkit жишээ
---

# 1. Танилцуулга

Энэ нь `gerege-doc-toolkit`-ийн **хамгийн жижиг** жишээ. Зөвхөн `title`-той
frontmatter — үлдсэн нь default value-аар нүүр хуудаст гарна.

## 1.1 Зориулалт

Toolkit зөв ажилладаг эсэхийг шалгах test файл.

## 1.2 Хэрхэн ашиглах

```bash
../scripts/build.sh 01-simple-document.md
open dist/01-simple-document.docx
```

# 2. Тестилэх агуулга

## 2.1 Текст хэлбэр

**Bold**, *italic*, `inline code`, ~~strikethrough~~.

## 2.2 Жагсаалт

- Bullet 1
- Bullet 2
  - Nested bullet
  - Дахин нэг
- Bullet 3

1. Numbered 1
2. Numbered 2
3. Numbered 3

## 2.3 Хүснэгт

| Зүйл | Утга |
|---|---|
| A | 100 |
| B | 200 |
| C | 300 |

## 2.4 Кодын блок

```bash
echo "Hello, Gerege"
date
```

## 2.5 Blockquote

> Нөхцөл байдалаас үл хамаарна. Үнэн зөв байх.

# 3. Хувилбарын түүх

| Хувилбар | Огноо | Өөрчлөлт |
|---|---|---|
| 0.1.0 | 2026-04-29 | Анхны хувилбар |
