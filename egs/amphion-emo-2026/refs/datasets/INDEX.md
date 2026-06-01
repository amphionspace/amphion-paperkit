# Dataset Index — amphion-emo-2026

> Human-readable view. Source of truth is `INDEX.yaml`.

## Group 1: SER Evaluation Benchmarks

| Dataset | Language | Classes | Split Used |
|---------|----------|---------|------------|
| IEMOCAP | English | 4 (mapped) | Session 5 |
| MSP-Podcast | English | 8 | Test Set 1 |
| MELD | English | 7 | standard test |
| M3ED | Chinese | 7 | standard test |
| BIIC-Podcast | Chinese | 8 | standard test |

## Group 2: Auxiliary ASR Datasets

| Dataset | Language | Used For |
|---------|----------|---------|
| LibriSpeech | English | ASR eval |
| CommonVoice | English | ASR eval |
| WenetSpeech | Chinese | ASR eval + training |
| AISHELL-1 | Chinese | ASR eval + training |
| GigaSpeech | English | ASR training |

## Group 3: Noise Augmentation Sources

| Dataset | Used For |
|---------|---------|
| DNS Challenge 4 (AudioSet + Freesound) | Background noise |
| MUSAN | Background noise / speech |
| RIR datasets | Room impulse responses |
