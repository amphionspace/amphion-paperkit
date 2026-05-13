背景
- 总目标是出一个技术报告，内容关于一个4.3B的LLM ASR模型，其主要特点包括
  - 中英识别率领先（不可太差）
  - 支持热词（自有测试机上SOTA）
  - 支持目标说话人识别（自有/开源测试集上SOTA）
  - 对现实场景的高抗噪（优于Qwen3-ASR-1.7B）

模型信息
- 平台：HPC
- 账号：chenmingjie
- 仓库：https://github.com/amphionspace/AmphionASR/tree/feat/target_speaker
- 代码位置：/chenmingjie/mingdong/workspace/AmphionASR
- Conda环境
  - vllm部署/测试：vllm
  - ms-swift训练：amphionft
- 最佳权重
  /chenmingjie/mingdong/workspace/AmphionASR/exp/qwen3asr_aut_qwen3_4b_continue_sft_ts_hw_v3

当前进展
模型能力
- 数据见数据表格
总结
- Hotwords
  - 支持情况：已支持
  - 测试进度：中文热词sota，英文热词未测
- TS-ASR
  - 支持情况：已支持
  - 测试进度：自有测试集SOTA，libri2mix较差，原因未排查
- Hotwords+TS-ASR
  - 支持情况：已支持
  - 测试进度：无
- 高抗噪
  - 支持情况：未支持
  - 测试进度：无

关乎测试
- 使用 /chenmingjie/mingdong/workspace/AmphionASR/src/integrations/scripts/deploy/serve_vllm.sh 部署模型
- 直接问：integrations中的测试方法：vllm+eval plan
待办
1. 测试、补齐模型能力
  - Hotwords
    - 目标：有热词情况下，中英Commonvoice SOTA
    - 动作：测试Commonvoice-en英文测试集，视情况而动@李煦 
  - TS-ASR
    - 目标：自有测试集和开源测试集均SOTA
    - 动作：排查libri2mix测试集较差的原因，再决定下一步@李煦 
  - Hotwords+TS-ASR
    - 目标：加入热词后，在TS-ASR测试集上的错误率进一步降低
    - 动作：
      - 制备TS-ASR热词测试集 @余铭栋 
      - 测试@李煦 
  - 中英识别率
    - 目标：降低英文ASR错误率
    - 动作：继续SFT，加入英文ASR数据@李煦 
  - 高抗噪
    - 目标：超越Qwen3-ASR-1.7B
    - 动作：
      - 搜罗Qwen3-ASR-1.7B表现不好的噪声测试集@余铭栋 @李煦 
        - Whisper-RIR-Mega test：/ai_sds_wuzz/MULTILINGUAL_DATA/noise/rirmega/data/manifests
          - 已归档：是
          - 已测试：否
      - 训进模型@李煦 
2. 补齐开源模型数据@李煦 
  - 目前已有
    - 2026.04开源Audio模型评估（ASR+SER）
    - 外部 ASR 测评结果
3. 技术报告@李煦 @余铭栋 
  1. 确定框架，Introduction
  2. 填充内容、实验数据
  3. 润色
