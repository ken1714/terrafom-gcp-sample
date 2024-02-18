import http from 'http'
import fs from 'fs'
import 'dotenv/config'
import {GoogleAuth} from 'google-auth-library';

const auth = new GoogleAuth();


console.log('Server Start!');

const sendRequest2Backend = async (apiPath) => {
    const requestUrl = process.env.BACKEND_URL || 'http://localhost';

    const client = await auth.getIdTokenClient(process.env.TARGET_AUDIENCE);
    const response = await client.request({
        url: `${requestUrl}${apiPath}`,
        method: 'GET',
    });
    return response.data;
};

const responseData = await sendRequest2Backend('/api/get');

// httpサーバーを作成
const PORT = process.env.PORT || 3000;
const server = http.createServer(async (req, res) => {
    fs.readFile('./index.html', 'utf-8', async (error, data) => {
        await res.writeHead(200, {'Content-Type': 'text/html'});
        await res.write(responseData.message);
        await res.end();
    });
});

server.listen(PORT);
