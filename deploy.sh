#!/bin/bash

# =====================================================
# 🚀 腾讯云 COS 部署脚本 - 儿童英语游戏
# =====================================================

# ============ 配置区域（请修改以下内容）============

# 存储桶名称（必须全局唯一）
BUCKET_NAME="your-bucket-name"

# 存储桶地域（如：ap-hongkong, ap-shanghai, ap-beijing）
REGION="ap-hongkong"

# 本地项目目录（默认当前目录）
LOCAL_DIR="."

# COS 中的目标路径（默认根目录）
COS_PATH="/"

# =====================================================

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 构建 endpoint
ENDPOINT="cos.$REGION.myqcloud.com"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   🚀 腾讯云 COS 部署脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查 coscli 是否安装
if ! command -v coscli &> /dev/null; then
    echo -e "${RED}❌ 错误：未找到 coscli 工具${NC}"
    echo ""
    echo "请先安装腾讯云 COS CLI："
    echo "  macOS: brew install tencent-cloud-cos-cli"
    echo "  或: pip install coscmd"
    echo ""
    echo "安装后运行: coscli config init"
    exit 1
fi

echo -e "${GREEN}✅ coscli 已安装${NC}"

# 检查是否已配置凭证
if ! coscli config show &> /dev/null; then
    echo -e "${YELLOW}⚠️  未找到 COS 配置${NC}"
    echo "请先运行: coscli config init"
    echo ""
    echo "需要准备："
    echo "  1. SecretId（腾讯云 API 密钥）"
    echo "  2. SecretKey（腾讯云 API 密钥）"
    echo "  3. Endpoint: $ENDPOINT"
    exit 1
fi

echo -e "${GREEN}✅ COS 配置已存在${NC}"

# 检查存储桶名称是否已修改
if [ "$BUCKET_NAME" = "your-bucket-name" ]; then
    echo -e "${RED}❌ 错误：请先修改脚本中的 BUCKET_NAME${NC}"
    echo ""
    echo "请编辑 deploy.sh，将："
    echo '  BUCKET_NAME="your-bucket-name"'
    echo "修改为："
    echo '  BUCKET_NAME="你的真实存储桶名称"'
    exit 1
fi

echo ""
echo -e "${BLUE}📋 部署信息：${NC}"
echo "  存储桶: $BUCKET_NAME"
echo "  地域: $REGION"
echo "  Endpoint: $ENDPOINT"
echo ""

# 确认部署
echo -e "${YELLOW}⚠️  即将部署到腾讯云 COS${NC}"
echo "旧文件将被删除并替换为最新版本"
echo ""
read -p "是否继续? (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo -e "${YELLOW}已取消部署${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🔄 开始部署...${NC}"

# 创建 index.html 作为入口
echo -e "${YELLOW}📄 创建 index.html...${NC}"
cp "英语游戏中心.html" index.html

# 删除旧文件（可选，如果需要保留历史版本可以注释掉）
echo -e "${YELLOW}🗑️  清理旧文件...${NC}"
coscli rm cos://$BUCKET_NAME$COS_PATH -r -f

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  清理旧文件失败或存储桶为空，继续上传...${NC}"
fi

# 上传新文件
echo -e "${YELLOW}📤 上传新文件...${NC}"
coscli cp -r $LOCAL_DIR cos://$BUCKET_NAME$COS_PATH

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 上传失败${NC}"
    rm -f index.html
    exit 1
fi

# 清理临时文件
rm -f index.html

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ✅ 部署成功！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}🌐 访问地址：${NC}"
echo "  https://$BUCKET_NAME.cos-website.$REGION.myqcloud.com"
echo ""
echo -e "${BLUE}📊 管理控制台：${NC}"
echo "  https://console.cloud.tencent.com/cos/bucket"
echo ""
echo -e "${YELLOW}💡 提示：${NC}"
echo "  - 如果无法访问，请检查存储桶是否开启「静态网站」功能"
echo "  - 默认首页应设置为 index.html"
echo "  - 首次访问可能需要等待 1-2 分钟 CDN 生效"
