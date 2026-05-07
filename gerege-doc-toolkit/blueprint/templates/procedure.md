---
title: <<TBD: Procedure-ийн нэр>>
owner: <<TBD>>
priority: P1
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: internal
---

# <<TBD: Procedure нэр>>

> **Зорилго.** <<TBD: 1-2 өгүүлбэрээр процедурийн зорилгыг хэлэх>>.

## 1. Хэрэглэгдэх үе

| Trigger | Хэн уг | Frequency |
|---|---|---|
| <<TBD>> | <<TBD: role>> | <<TBD: ежемесячно / on-demand / yearly>> |

## 2. Урьдчилан бэлтгэл

### 2.1 Эд зүйлсийн жагсаалт

```
[ ] <<TBD: tool / hardware>>
[ ] <<TBD>>
[ ] <<TBD>>
```

### 2.2 Хэн оролцох вэ

| Үүрэг | Нэр / Role |
|---|---|
| Лидер (Owner) | <<TBD>> |
| Witness 1 | <<TBD>> |
| Witness 2 | <<TBD>> |

### 2.3 Орчны хяналт

<<TBD: physical / network / time-of-day requirements>>

### 2.4 Хуваарь

| Цаг | Үйлдэл |
|---|---|
| 09:00 | <<TBD: first action>> |
| 09:30 | <<TBD>> |
| 10:00 | <<TBD>> |

## 3. Procedure (step-by-step)

### Step 1: <<TBD: Эхний алхам>>

```
1. <<TBD: substep>>
2. <<TBD: substep>>
3. <<TBD: substep>>
```

**Witness check:**

```
[ ] <<TBD: verification 1>>
[ ] <<TBD: verification 2>>
```

### Step 2: <<TBD: Дараагийн алхам>>

```
1. <<TBD>>
2. <<TBD>>
```

```bash
# Sample command
$ <<TBD: command>>
```

### Step 3: <<TBD>>

(Repeat...)

## 4. Verification

```
[ ] <<TBD: success criterion 1>>
[ ] <<TBD: success criterion 2>>
[ ] <<TBD: артефакт хадгалагдсан>>
```

## 5. Witness Sheet

Procedure нь dual-control шаардсан бол witness sheet (Хавсралт А).

## 6. Audit-аар үлдэх артефакт

| Артефакт | Хадгалах байршил | Retention |
|---|---|---|
| Witness sheet (PDF + scan) | `08-audit-evidence/<procedure>/` | <<TBD: 7 years>> |
| Видео (encrypted) | <<TBD: encrypted USB / S3>> | <<TBD>> |
| Configuration snapshot | git | indefinite |
| Output files (e.g., generated cert) | <<TBD>> | <<TBD>> |

## 7. Error / Abort procedure

Procedure явагдах үед алдаа гарвал:

| Алдаа | Хариу |
|---|---|
| <<TBD: minor error>> | <<TBD: retry approach>> |
| <<TBD: major error>> | <<TBD: STOP. Document. Reschedule.>> |
| <<TBD: tamper evidence>> | <<TBD: STOP. ABORT. Notify Legal.>> |

Abort бүрд:

```
[ ] Reason бичигдэх
[ ] All participants sign abort document
[ ] Any partial state securely destroyed
```

## 8. Цэвэрлэгээ

```
[ ] <<TBD: workspace cleaned>>
[ ] <<TBD: temp data wiped>>
[ ] <<TBD: tools returned>>
[ ] <<TBD: video stopped + secured>>
```

## 9. Frequency / Schedule

- <<TBD: e.g., Жил бүр Q1>>
- <<TBD: e.g., Compromise-аас хойш яаралтай>>

---

## Хавсралт А — Witness Sheet

```
══════════════════════════════════════════════════════════════════════
                    <<TBD: PROCEDURE-ИЙН НЭР>> WITNESS SHEET
══════════════════════════════════════════════════════════════════════

Procedure ID:  <<TBD>>
Огноо:         ____________________  Цаг (UTC+8): ___________
Газар:         ___________________________________________________

──────────────────────────────────────────────────────────────────────
Оролцогчид
──────────────────────────────────────────────────────────────────────

Лидер  : __________________________  Гарын үсэг: ______
Witness 1   : __________________________  Гарын үсэг: ______
Witness 2   : __________________________  Гарын үсэг: ______

──────────────────────────────────────────────────────────────────────
Гүйцэтгэсэн алхмуудын баталгаа
──────────────────────────────────────────────────────────────────────

[ ] Step 1 хийгдсэн
[ ] Step 2 хийгдсэн
[ ] Step 3 хийгдсэн
[ ] Verification PASS

──────────────────────────────────────────────────────────────────────
Тэмдэглэл
──────────────────────────────────────────────────────────────────────

(зайтай 5 мөр)

══════════════════════════════════════════════════════════════════════
```

## Хавсралт Б — Хувилбарын түүх

| Хувилбар | Огноо | Өөрчлөлт |
|---|---|---|
| 1.0.0 | 2026-MM-DD | Анхны хувилбар |
