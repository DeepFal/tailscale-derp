# tailscale-derp

这是一个面向直接使用镜像的 DERP 构建仓库，不面向二次开发。

## 这个版本的差异

- 基于上游最新 `tailscale.com/cmd/derper` 构建。
- 打了一个兼容性补丁：移除 `cert mismatch with hostname: %q` 这一行校验报错逻辑。
- 镜像持续自动更新，提供两个标签：
  - `latest`
  - `vX.Y.Z`（对应 Tailscale 发布版本）

## 直接拉取使用

```bash
docker pull deepfal/tailscale-derp:latest
docker pull deepfal/tailscale-derp:v1.94.1
```

> 一般直接使用 `latest` 即可；需要可复现部署时使用固定版本标签。
