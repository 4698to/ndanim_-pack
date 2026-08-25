天晴盒子安装器 - 统一发布包

将本目录全部文件复制到：
  C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\

入口程序（可只保留一个，或两个都部署）：

1) NDDownload.exe  — 公网版（仅腾讯云服务器）

2) NDDownloadIn.exe — 内网版（仅公司内网服务器）

打包：在仓库根目录执行
  .\build-channels.ps1 -Configuration Release
