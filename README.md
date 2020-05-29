## quic-web

支持 QUIC 和 HTTP3 协议的 web 服务 Docker 镜像，Demo: [https://http3.godjiyi.cn:9445/](https://http3.godjiyi.cn:9445/)

**HTTP1.1** VS **HTTP2** VS **HTTP3** 加载速度对比: [https://demo.godjiyi.cn](https://demo.godjiyi.cn)

![](./_img/quic.jpg)

<a href="./_img/quic46.png" target="_blank">大图1<a/> <a href="./_img/quic50.png" target="_blank">大图2<a/>  <a href="./_img/http3.png" target="_blank">大图3<a/>

注：

* Chrome 浏览器目前仅支持自家的 QUIC，quic/46 是完全自家的，h3-Q050 这则是 gquic 逐渐向 IETF 规范靠拢；
* Firefox 浏览器则支持的是 IETF 官方 HTTP3，但 HTTP3 仍在草稿中，因此实现的是 HTTP3 各个阶段的 Draft 手稿协议。
* 详细说明 QUIC 和 HTTP3 区别见。

### 文件结构

<a href="./_img/quic-web-arc.png"><img alt="logo" width="500" height="300" src="./_img/quic-web-arc.png" alt="quic-web">
    </a>


主要思路 Nginx 负责作为 Server，而 **openlitespeed** 服务只作为 **QUIC/HTTP3** 服务使用，而 QUIC/HTTP3 是通过 UDP 建立连接的。因此，只要将 Nginx 的 443 端口的 UDP 信息转发到 **openlitespeed** 服务即可。

### 准备

* 一个域名，如：**http3.godjiyi.cn**;
* 域名证书，分别将 crt 和 key 文件重命名:
	* **domain.crt**
	* **domain.key** 

* 依赖 [http-base-quic](https://hub.docker.com/repository/docker/jiyiren/http-base-quic) 基础镜像;

### 配置

* 下载库和基础镜像

	```bash
	# 下载代码
	git clone https://github.com/jiyiren/quic-web.git
	# 下载基础镜像
	docker push jiyiren/http-base-quic:v1.0.0
	```

* 替换 `libs/ssl/` 下的证书;
* 配置 `httpd_config.conf`:

	* 只需配置 `httpd_config.conf` 的最后一段信息;
	* **address**: 为端口号，由于我们用了一层 Nginx 代理，这里不用修改;
	* **keyFile/certFile**: 如果大家上一步重名名了则不用变动，如果没有，则改为自己的 key/crt 名;
	* **map**: 只需要修改域名，如果你的域名为：http3.godjiyi.cn, 则改为：

		```nginx
		map                     http_proxy_quic http3.godjiyi.cn
		```
	* 完整示例:

		```nginx
		listener QUIC8443 {
		  address                 *:8443
		  secure                  1
		  keyFile                 /opt/ssl/domain.key
		  certFile                /opt/ssl/domain.crt
		  certChain               1
		  sslProtocol             28
		  renegProtection         1
		  sslSessionCache         1
		  sslSessionTickets       1
		  enableSpdy              15
		  enableQuic              1
		  map                     http_proxy_quic http3.godjiyi.cn
		}
		```
	
	
* 配置 `nginx.conf`:

	* 熟悉 nginx 配置的可忽略;
	* 主要配置域名和证书，如果严格按照上面步骤来，则只需要改下域名即可:

		```nginx
		server_name  http3.godjiyi.cn;
		```
	* www 路径，则大家只需将自己的站点放在 `libs/www/` 下面即可，如果不是，则自己修改根路径；
	* 完整示例代码里已经有注释说明了，大家可以参考。

### 构建和运行

构建镜像：

```bash
docker build -f Dockerfile -t myhttp3:0.0.1 .
```

然后在服务器上，运行镜像，比如你只想让镜像监听在服务器的 9445 端口，而不是 80 端口，则按下面方式运行即可：

```bash
docker run -d --name myhttp3 -p 9445:443/tcp -p 9445:8443/udp  myhttp3:0.0.1
```

将域名绑定到你的服务器 ip，访问: https://yourip:9445 即可展示支持 QUIC/HTTP3 的网站。

我的 demo 网站为: [https://http3.godjiyi.cn:9445/](https://http3.godjiyi.cn:9445/)