# ================= 构建阶段 =================
FROM golang:alpine AS builder

# 1. 基础环境配置
WORKDIR /build

# 使用多代理提高模块拉取稳定性
ENV GOPROXY=https://proxy.golang.org,https://goproxy.cn,direct

# 2. 拉取代码
ARG DERPER_REF=latest
RUN go install tailscale.com/cmd/derper@${DERPER_REF}

# 3. 查找源码路径并修补
RUN derper_dir=$(find /go/pkg/mod/tailscale.com@*/cmd/derper -type d) && \
    cd $derper_dir && \
    grep -Fq 'cert mismatch with hostname: %q' cert.go || (echo "patch target not found in cert.go" >&2; exit 1) && \
    sed -i '/cert mismatch with hostname: %q/d' cert.go && \
    ! grep -Fq 'cert mismatch with hostname: %q' cert.go || (echo "patch did not apply cleanly" >&2; exit 1) && \
    # 4. 静态编译 (CGO_ENABLED=0)
    # 编译出不依赖系统库的纯净二进制文件
    CGO_ENABLED=0 go build -ldflags "-s -w" -o /build/derper .

# ================= 运行阶段 =================
FROM alpine:latest

WORKDIR /apps

# 1. 安装必要依赖
RUN apk add --no-cache tzdata openssl ca-certificates

# 2. 设置时区 (修正为国内时区，方便看日志)
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 3. 复制编译好的二进制文件
COPY --from=builder /build/derper .

# 4. 生成自签证书
# 生产环境建议通过 -v 挂载证书目录，不要每次都重新生成
RUN mkdir /ssl && \
    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout /ssl/derp.deepfal.cn.key \
    -out /ssl/derp.deepfal.cn.crt \
    -subj "/CN=derp.deepfal.cn" \
    -addext "subjectAltName=DNS:derp.deepfal.cn"

ENV LANG=C.UTF-8

# 5. 启动命令
CMD ["./derper", "-hostname", "derp.deepfal.cn", "-a", ":36666", "-certmode", "manual", "-certdir", "/ssl"]
