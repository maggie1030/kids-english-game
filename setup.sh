#!/bin/bash

# =====================================================
# 🛠️ 腾讯云 COS 部署环境一键配置脚本
# =====================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   🛠️ 腾讯云 COS 环境配置工具${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检测操作系统
OS="$(uname -s)"
case "$OS" in
    Darwin*) PLATFORM="macOS" ;;
    Linux*)  PLATFORM="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) PLATFORM="Windows" ;;
    *) PLATFORM="Unknown" ;;
esac

echo -e "${BLUE}检测到操作系统: $PLATFORM${NC}"
echo ""

# 安装 coscli
install_coscli() {
    echo -e "${YELLOW}📦 正在安装腾讯云 COS CLI...${NC}"

    if [ "$PLATFORM" = "macOS" ]; then
        if command -v brew &> /dev/null; then
            brew install tencent-cloud-cos-cli
        else
            echo -e "${YELLOW}未找到 Homebrew，使用手动安装...${NC}"
            curl -L https://github.com/tencentyun/coscli/releases/latest/download/coscli-darwin-amd64 -o coscli
            chmod +x coscli
            sudo mv coscli /usr/local/bin/
        fi
    elif [ "$PLATFORM" = "Linux" ]; then
        curl -L https://github.com/tencentyun/coscli/releases/latest/download/coscli-linux-amd64 -o coscli
        chmod +x coscli
        sudo mv coscli /usr/local/bin/
    elif [ "$PLATFORM" = "Windows" ]; then
        echo -e "${YELLOW}Windows 用户请手动下载:${NC}"
        echo "https://github.com/tencentyun/coscli/releases"
        exit 1
    fi

    echo -e "${GREEN}✅ coscli 安装完成${NC}"
}

# 检查并安装 coscli
if ! command -v coscli &> /dev/null; then
    install_coscli
else
    echo -e "${GREEN}✅ coscli 已安装: $(coscli --version)${NC}"
fi

echo ""
echo -e "${BLUE}🔧 现在开始配置腾讯云凭证${NC}"
echo ""
echo "你需要准备以下信息（从腾讯云控制台获取）："
echo "  1. SecretId"
echo "  2. SecretKey"
echo "  3. 存储桶地域（如：ap-hongkong, ap-shanghai）"
echo ""
echo -e "${YELLOW}获取方式：${NC}"
echo "  1. 访问 https://console.cloud.tencent.com/cam/capi"
echo "  2. 点击「新建密钥」获取 SecretId 和 SecretKey"
echo "  3. 访问 https://console.cloud.tencent.com/cos/bucket"
echo "  4. 创建存储桶，记录地域信息"
echo ""
read -p "按回车键开始配置..."

# 配置 coscli
echo ""
echo -e "${YELLOW}📝 请按提示输入信息：${NC}"
coscli config init

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ✅ 环境配置完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}下一步：${NC}"
echo "  1. 编辑 deploy.sh，修改 BUCKET_NAME 和 REGION"
echo "  2. 运行 ./deploy.sh 开始部署"
echo ""
echo -e "${YELLOW}⚠️  重要提醒：${NC}"
echo "  SecretId 和 SecretKey 是敏感信息，请勿泄露！"
echo "  已保存在 ~/.cos.yaml 文件中，请妥善保管。"
