# AiZynthFinder 部署指南

本文档提供在常见操作系统上部署并运行 [AiZynthFinder](https://github.com/MolecularAI/aizynthfinder) 的完整步骤，帮助你从零开始搭建环境并成功运行命令行工具。

## 0. 一键部署脚本

如果你已经克隆了仓库，并希望快速获得可直接使用的环境，可以直接运行仓库提供的脚本：

```bash
./scripts/deploy_aizynthfinder.sh
```

该脚本会自动完成以下步骤：

1. 在仓库目录下创建 `.aizynthfinder-venv` 虚拟环境，并安装 AiZynthFinder（默认包含全部可选组件）。
2. 将公开模型和库存数据下载到 `~/aizynth-data`（可通过传入第一个参数自定义目录）。
3. 生成一个示例 `example_smiles.txt` 文件，并运行一次 `aizynthcli` 进行冒烟测试。

脚本具备幂等性，可以在需要更新安装时重复执行。如果只想安装核心功能，可在执行脚本前运行 `export AIZYNTH_EXTRAS=`（Windows PowerShell 可执行 `$env:AIZYNTH_EXTRAS=''`）。如果你更喜欢手动执行每一步，请继续阅读下文的详细指南。

## 1. 准备工作

在开始前，请确保：

- 你的系统为 Linux、macOS 或 Windows（PowerShell 或 WSL）。
- 已安装 Python 3.9 - 3.11（推荐使用 [Miniconda](https://docs.conda.io/en/latest/miniconda.html) 或 [Anaconda](https://www.anaconda.com/) 管理环境）。
- 有可访问互联网的终端，用于下载依赖和示例数据。

## 2. 克隆仓库

```bash
# 任选合适的目录并克隆仓库
git clone https://github.com/MolecularAI/aizynthfinder.git
cd aizynthfinder
```

## 3. 创建并激活独立环境

使用 Conda：

```bash
conda create "python>=3.9,<3.12" -n aizynth-env
conda activate aizynth-env
```

或者使用 `venv`：

```bash
python3 -m venv .venv
# Linux / macOS
source .venv/bin/activate
# Windows PowerShell
.venv\\Scripts\\Activate.ps1
```

## 4. 安装 AiZynthFinder

```bash
python -m pip install --upgrade pip
python -m pip install ".[all]"
```

> 如果只想安装核心功能，可将最后一条命令替换为 `python -m pip install .`。

安装完成后，系统会提供两个可执行命令：

- `aizynthcli`：命令行界面
- `aizynthapp`：图形界面（需要额外依赖）

## 5. 下载公开数据并生成配置

AiZynthFinder 需要库存文件和策略网络。可执行仓库中提供的下载工具：

```bash
# 选择一个用于存放数据和配置的目录，例如 ~/aizynth-data
download_public_data ~/aizynth-data
```

命令会自动下载模型与库存文件，并在目标目录生成 `config.yml`。

## 6. 准备输入分子

创建一个包含 SMILES 表达式的文本文件，每行一个分子。例如：

```bash
cat <<'EOL' > example_smiles.txt
CCO
CC(=O)Oc1ccccc1C(=O)O
EOL
```

## 7. 运行命令行工具

使用下载的配置文件运行搜索：

```bash
aizynthcli --config ~/aizynth-data/config.yml --smiles example_smiles.txt --output results.json
```

- `--config` 指定配置文件位置。
- `--smiles` 指定输入分子列表。
- `--output` 可选参数，指定结果保存路径（默认为当前目录）。

命令结束后，可以在终端查看摘要，或打开 `results.json` 查看完整搜索结果。

## 8. 常见问题排查

| 问题 | 可能原因 | 解决方案 |
| ---- | -------- | -------- |
| 找不到 `aizynthcli` 或 `download_public_data` 命令 | 环境未激活或 PATH 未更新 | 确认已激活步骤 3 创建的环境，或重新打开终端再激活环境 |
| 下载数据失败 | 网络受限或目标目录无写权限 | 更换网络、使用 VPN，或选择有写权限的目录重试 |
| 运行 `aizynthcli` 时提示缺少模型文件 | `config.yml` 路径填写错误 | 确认 `--config` 指向 `download_public_data` 生成的文件 |
| 安装依赖失败 | Pip 或 Conda 缓存问题 | 运行 `pip cache purge` 或 `conda clean --all` 后重试 |

## 9. 下一步

- 参考官方文档获取更多使用技巧：<https://molecularai.github.io/aizynthfinder/>
- 若需图形界面体验，可执行 `aizynthapp --config ~/aizynth-data/config.yml`。
- 可通过 `pytest -v` 运行单元测试验证安装完整性（开发者选项）。

按照以上步骤即可在本地完成 AiZynthFinder 的部署并开始使用。如遇到未覆盖的问题，可查阅官方文档或在 GitHub 提交 issue 寻求帮助。
