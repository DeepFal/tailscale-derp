# tailscale-derp

可直接使用的 DERP 去除域名验证补丁镜像。

## 补丁目的

- 目标是部署 `IP + 端口 + --verify-clients` 的自建 DERP。
- 补丁移除了 `cert mismatch with hostname` 这一步域名强校验，便于在 Tailscale Admin 里按 `IP:端口` 接入。
- 安全性仍由 `--verify-clients` 保证（仅允许你 tailnet 的客户端通过）。
- 对国内场景更友好：不依赖公网域名备案流程即可落地。

## 镜像标签

- `deepfal/tailscale-derp:latest`
- `deepfal/tailscale-derp:v1.94.1`（对应 Tailscale 发布版本）

## 自动同步状态

- 最新同步版本：`v1.94.1`
- 最后检查时间（UTC）：`2026-02-12 08:14 UTC`
- 上一次构建结果：`skipped`
- 最后构建更新时间（UTC）：`2026-02-12 08:13 UTC`

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
