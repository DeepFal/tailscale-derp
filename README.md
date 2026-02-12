# tailscale-derp

自动构建并推送自定义 DERP 镜像（带 hostname 校验补丁）。

## 功能

- 基于上游 `tailscale.com/cmd/derper@latest` 构建。
- 自动打补丁，去掉 `cert mismatch with hostname` 校验报错行。
- 自动推送两个标签：
  - `latest`
  - `vX.Y.Z`（Tailscale 最新 release 标签）
- GitHub Actions 每 6 小时检查一次上游 release；如果该版本标签已存在则跳过。

## 仓库结构

- `dockerfile`: DERP 镜像构建文件。
- `.github/workflows/build-and-push.yml`: 自动检测、构建、推送工作流。

## 首次使用

1. 在 GitHub 新建仓库并推送本目录。
2. 在仓库 Settings -> Secrets and variables -> Actions 添加：
   - `DOCKERHUB_USERNAME`: 你的 Docker Hub 用户名（例如 `deepfal`）
   - `DOCKERHUB_TOKEN`: Docker Hub Access Token
3. 在 Actions 页面手动触发一次 `Build and Push DERP Image`。

## 本地手动构建

```bash
sudo docker build -f dockerfile -t deepfal/tailscale-derp:latest .
sudo docker push deepfal/tailscale-derp:latest
```
