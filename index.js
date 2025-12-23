import http from "http";
import fs from "fs";

const PORT = process.env.PORT || 3000;
const DATA = "./.data";

const uuid = fs.readFileSync(`${DATA}/uuid.txt`, "utf-8").trim();

const html = `
<!DOCTYPE html>
<html>
<head>
  <title>Welcome</title>
  <meta charset="utf-8">
</head>
<body>
<h2>Service Online</h2>
<p>Status: OK</p>
</body>
</html>
`;

http.createServer((req, res) => {
  if (req.url === "/sub") {
    const ip = req.socket.localAddress || "0.0.0.0";
    const list = `
tuic://${uuid}:admin@${ip}:24579?alpn=h3#TUIC
hysteria2://${uuid}@${ip}:25157/?insecure=1#HY2
vless://${uuid}@${ip}:25157?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.nazhumi.com&type=tcp#Reality
`.trim();
    res.end(Buffer.from(list).toString("base64"));
    return;
  }

  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(html);
}).listen(PORT);

console.log("[Node] Web + watchdog online");
