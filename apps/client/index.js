import fetch from 'node-fetch';
import http from 'http'
import fs from 'fs'
import 'dotenv/config'


console.log('Server Start!');

const requestUrl = process.env.BACKEND_URL || 'http://localhost';
const requestPort = process.env.BACKEND_PORT || 3000;
const apiPath = "/api/get"
const response = await fetch(`${requestUrl}:${requestPort}${apiPath}`, {method: 'GET'});
const responseData = await response.text();

// httpサーバーを作成
const PORT = process.env.PORT || 3000;
const server = http.createServer(async (req, res) => {
    fs.readFile('./index.html', 'utf-8', async (error, data) => {
        res.writeHead(200, {'Content-Type': 'text/html'});
        res.write(data);
        res.write(responseData);
        res.end();
    });
});

server.listen(PORT);
