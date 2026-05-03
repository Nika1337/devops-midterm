const fs = require('fs');
const http = require('http');
const path = require('path');

const PORTS = {
  blue: 3001,
  green: 3002
};

const activeEnvFile = path.join(__dirname, '..', 'deployments', 'active-env.txt');

function getActiveEnvironment(filePath = activeEnvFile) {
  return fs.readFileSync(filePath, 'utf8').trim();
}

function getTargetPort(environment) {
  return PORTS[environment] || null;
}

function createProxyServer() {
  return http.createServer((clientRequest, clientResponse) => {
    let activeEnvironment;

    try {
      activeEnvironment = getActiveEnvironment();
    } catch {
      clientResponse.writeHead(502, { 'Content-Type': 'text/plain' });
      clientResponse.end('Unable to read active environment.');
      return;
    }

    const targetPort = getTargetPort(activeEnvironment);

    if (!targetPort) {
      clientResponse.writeHead(502, { 'Content-Type': 'text/plain' });
      clientResponse.end('Invalid active environment.');
      return;
    }

    const proxyRequest = http.request(
      {
        hostname: 'localhost',
        port: targetPort,
        path: clientRequest.url,
        method: clientRequest.method,
        headers: clientRequest.headers
      },
      (proxyResponse) => {
        clientResponse.writeHead(proxyResponse.statusCode, proxyResponse.headers);
        proxyResponse.pipe(clientResponse);
      }
    );

    proxyRequest.on('error', () => {
      clientResponse.writeHead(502, { 'Content-Type': 'text/plain' });
      clientResponse.end(`Active environment ${activeEnvironment} is not reachable.`);
    });

    clientRequest.pipe(proxyRequest);
  });
}

if (require.main === module) {
  const proxyPort = process.env.PROXY_PORT || 3000;

  createProxyServer().listen(proxyPort, () => {
    console.log(`Blue-green proxy is running on port ${proxyPort}`);
    console.log('Requests are routed using deployments/active-env.txt');
  });
}

module.exports = {
  createProxyServer,
  getTargetPort
};
