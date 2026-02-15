# tailscale-derp

[![Build and Push DERP Image](https://github.com/DeepFal/tailscale-derp/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/DeepFal/tailscale-derp/actions/workflows/build-and-push.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/deepfal/tailscale-derp)](https://hub.docker.com/r/deepfal/tailscale-derp)
[![Docker Image Version](https://img.shields.io/docker/v/deepfal/tailscale-derp?sort=semver)](https://hub.docker.com/r/deepfal/tailscale-derp/tags)

可直接使用的 DERP 去除域名验证补丁镜像。

## 补丁目的

- 目标是部署 `IP + 端口 + --verify-clients` 的自建 DERP。
- 补丁移除了 `cert mismatch with hostname` 这一步域名强校验，便于在 Tailscale Admin 里按 `IP:端口` 接入。
- 安全性仍由 `--verify-clients` 保证（仅允许你 tailnet 的客户端通过）。
- 对国内场景更友好：不依赖公网域名备案流程即可落地。

## 实现原理

- 在 `cmd/derper/cert.go` 中删除 `getCertificate` 的 hostname 强校验返回逻辑（`cert mismatch with hostname`）。
- 其余行为保持上游默认：仍使用上游 DERPer 源码构建，并以 `CGO_ENABLED=0` 静态编译输出二进制。

> 风险提示：该补丁放宽了握手阶段的 SNI 严格匹配。建议保持 `--verify-clients` 开启，并在可信网络与正确证书配置下使用。

## 镜像标签

- `deepfal/tailscale-derp:latest`
- `deepfal/tailscale-derp:v1.94.1`（对应 Tailscale 发布版本）

## 自动同步状态

- 最新同步版本：`v1.94.1`
- 上次更新时间（UTC）：`2026-02-13 04:26 UTC`
- 上次检查时间（UTC）：`2026-02-15 02:02 UTC`

## 启动命令

```bash
docker run -d \
    --name tailscale-derp \
    --restart unless-stopped \
    -p 0.0.0.0:59443:36666 \
    -p 0.0.0.0:3478:3478/udp \
    -v /run/tailscale:/var/run/tailscale:ro \
    deepfal/tailscale-derp:latest \
    ./derper \
    -hostname derp.deepfal.cn \
    -a :36666 \
    -certmode manual \
    -certdir /ssl \
    --verify-clients
```

## 参考

- Tailscale Custom DERP docs: https://tailscale.com/kb/1118/custom-derp-servers
- `--verify-clients` 官方说明：用于限制仅你的 tailnet 客户端可用
