# Qwen3-Omni-30B-A3B-Instruct zero-shot TS-ASR evaluation

Source: author-provided evaluation report received on 2026-07-23.
Experiment date: 2026-07-22.

## Protocol

- Model: Qwen3-Omni-30B-A3B-Instruct.
- No TS-ASR fine-tuning; the task is specified only through the prompt.
- Each request contains an enrollment utterance followed by a mixture.
- Greedy decoding, maximum generation length 200 tokens.
- The exact output `<NO_TARGET_SPEECH>` is deterministically mapped to an
  empty hypothesis before scoring. Surrounding quotation marks, Markdown
  backticks, or a final period are ignored for this exact-match parser.

## Evaluation sets

| Set | Positive | Negative silence | Negative distractor | Total |
| --- | ---: | ---: | ---: | ---: |
| In-house TS-ASR | 6,227 | 164 | 164 | 6,555 |
| Libri2Mix | 6,000 | 0 | 0 | 6,000 |
| Libri3Mix | 9,000 | 0 | 0 | 9,000 |

## Results

| System | In-house WER | FA-silence | FA-distractor | Libri2Mix WER | Libri3Mix WER |
| --- | ---: | ---: | ---: | ---: | ---: |
| Qwen3-Omni-30B-A3B-Instruct | 31.91 | 9.15 | 75.00 | 72.58 | 91.57 |

The in-house overall false-alarm rate is 42.07% (138/328). Positive-slice
miss rates are 4.13% on the in-house set, 8.30% on Libri2Mix, and 9.53% on
Libri3Mix. All 21,555 requests completed successfully.

## Prompt

```text
Target-speaker transcription task. You will receive exactly two audio clips.

Audio 1 -- ENROLLMENT REFERENCE: Use it only to learn the target speaker's voice identity (timbre, pitch, accent, and speaking style). Do not transcribe or copy any words from Audio 1.
Audio 1:
<AUDIO_1_ENROLLMENT>

Audio 2 -- MIXTURE TO TRANSCRIBE: Identify the same speaker by voice characteristics, then transcribe only that speaker's intelligible words from Audio 2. Ignore every other speaker, background speech, noise, music, and overlap.

Output rules:
1. Output only the verbatim transcript; no explanation, label, speaker name, quotation marks, or markdown.
2. Never include words spoken only in Audio 1 or by a different speaker in Audio 2.
3. If the target speaker is absent or says nothing intelligible in Audio 2, output exactly <NO_TARGET_SPEECH>.
Expected transcript language: <LANGUAGE>.
Audio 2:
<AUDIO_2_MIXTURE>
```

The two audio placeholders are independent, ordered audio inputs. The language
placeholder is replaced by `zh` or `en` from sample metadata.
